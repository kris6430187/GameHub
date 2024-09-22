import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 50
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Logout", for: .normal)
        button.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let submitFeedbackButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Submit Feedback", for: .normal)
        button.addTarget(self, action: #selector(submitFeedbackTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let themeSwitch: UISwitch = {
        let themeSwitch = UISwitch()
        themeSwitch.translatesAutoresizingMaskIntoConstraints = false
        themeSwitch.addTarget(self, action: #selector(themeSwitchToggled), for: .valueChanged)
        return themeSwitch
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        loadUserProfile()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(changeProfilePicture))
        profileImageView.addGestureRecognizer(tapGesture)

        // Set switch based on the current theme
        themeSwitch.isOn = ThemeManager.shared.currentTheme == .dark
    }

    private func setupLayout() {
        view.addSubview(profileImageView)
        view.addSubview(nameLabel)
        view.addSubview(emailLabel)
        view.addSubview(logoutButton)
        view.addSubview(submitFeedbackButton)
        view.addSubview(themeSwitch)

        NSLayoutConstraint.activate([
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),

            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),

            emailLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),

            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 30),

            submitFeedbackButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            submitFeedbackButton.topAnchor.constraint(equalTo: logoutButton.bottomAnchor, constant: 20),

            themeSwitch.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            themeSwitch.topAnchor.constraint(equalTo: submitFeedbackButton.bottomAnchor, constant: 20)
        ])
    }

    private func loadUserProfile() {
        guard let user = Auth.auth().currentUser else { return }
        nameLabel.text = user.displayName ?? "No Name"
        emailLabel.text = user.email

        if let photoURL = user.photoURL {
            URLSession.shared.dataTask(with: photoURL) { data, _, error in
                if let data = data, error == nil {
                    DispatchQueue.main.async {
                        self.profileImageView.image = UIImage(data: data)
                    }
                }
            }.resume()
        } else {
            profileImageView.image = UIImage(systemName: "person.circle")
        }
    }

    @objc private func changeProfilePicture() {
        let alert = UIAlertController(title: "Profile Picture", message: "Choose a source", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.presentImagePicker(sourceType: .camera)
        }))
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
            self.presentImagePicker(sourceType: .photoLibrary)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else { return }
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        present(picker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[.originalImage] as? UIImage else { return }
        profileImageView.image = selectedImage
        uploadProfileImage(selectedImage)
    }

    private func uploadProfileImage(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.75),
              let user = Auth.auth().currentUser else { return }

        let storageRef = Storage.storage().reference().child("profile_images/\(user.uid).jpg")
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Failed to upload image: \(error.localizedDescription)")
                return
            }

            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Failed to retrieve download URL: \(error.localizedDescription)")
                    return
                }

                guard let url = url else { return }
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.photoURL = url
                changeRequest.commitChanges { error in
                    if let error = error {
                        print("Failed to update profile: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    @objc private func logoutTapped() {
        do {
            try Auth.auth().signOut()
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                let loginViewController = LoginViewController()
                let navigationController = UINavigationController(rootViewController: loginViewController)
                sceneDelegate.setRootViewController(navigationController)
            }
        } catch {
            print("Error signing out: \(error.localizedDescription)")
            showAlert(title: "Error", message: "Failed to sign out. Please try again.")
        }
    }

    @objc private func submitFeedbackTapped() {
        let alertController = UIAlertController(title: "Submit Feedback", message: "Please enter your feedback below:", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Your feedback here"
        }
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self] _ in
            guard let feedback = alertController.textFields?.first?.text, !feedback.isEmpty else {
                self?.showAlert(title: "Error", message: "Please enter your feedback.")
                return
            }
            
            self?.saveFeedbackToFirebase(feedback)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(submitAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func saveFeedbackToFirebase(_ feedback: String) {
        guard let userId = Auth.auth().currentUser?.uid else {
            showAlert(title: "Error", message: "User not logged in.")
            return
        }
        
        let db = Firestore.firestore()
        db.collection("feedback").addDocument(data: [
            "userId": userId,
            "feedback": feedback,
            "timestamp": FieldValue.serverTimestamp()
        ]) { error in
            if let error = error {
                print("Error saving feedback: \(error.localizedDescription)")
                self.showAlert(title: "Error", message: "Failed to submit feedback. Please try again.")
            } else {
                self.showAlert(title: "Success", message: "Your feedback has been submitted. Thank you!")
            }
        }
    }

    @objc private func themeSwitchToggled() {
        // Change theme using ThemeManager
        ThemeManager.shared.currentTheme = themeSwitch.isOn ? .dark : .light
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
