import UIKit
import FirebaseAuth
import FirebaseStorage
import MessageUI

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate {

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

    private let contactSupportButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Contact Support", for: .normal)
        button.addTarget(self, action: #selector(contactSupportTapped), for: .touchUpInside)
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

        // Add tap gesture to profile image view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(changeProfilePicture))
        profileImageView.addGestureRecognizer(tapGesture)

        // Set initial state of theme switch
        themeSwitch.isOn = traitCollection.userInterfaceStyle == .dark
    }

    private func setupLayout() {
        view.addSubview(profileImageView)
        view.addSubview(nameLabel)
        view.addSubview(emailLabel)
        view.addSubview(logoutButton)
        view.addSubview(contactSupportButton)
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

            contactSupportButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contactSupportButton.topAnchor.constraint(equalTo: logoutButton.bottomAnchor, constant: 20),

            themeSwitch.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            themeSwitch.topAnchor.constraint(equalTo: contactSupportButton.bottomAnchor, constant: 20)
        ])
    }

    private func loadUserProfile() {
        guard let user = Auth.auth().currentUser else { return }
        nameLabel.text = user.displayName ?? "No Name"
        emailLabel.text = user.email

        // Load profile image from Firebase Storage or a default image
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
            // Navigate back to the login screen
            let loginVC = LoginViewController()
            loginVC.modalPresentationStyle = .fullScreen
            present(loginVC, animated: true, completion: nil)
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }

    @objc private func contactSupportTapped() {
        if MFMailComposeViewController.canSendMail() {
            let mailComposeVC = MFMailComposeViewController()
            mailComposeVC.mailComposeDelegate = self
            mailComposeVC.setToRecipients(["support@example.com"])
            mailComposeVC.setSubject("Support Request")
            mailComposeVC.setMessageBody("Please describe your issue here.", isHTML: false)
            present(mailComposeVC, animated: true, completion: nil)
        } else {
            showAlert(title: "Mail Not Configured", message: "Please configure your mail account to send emails.")
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

    @objc private func themeSwitchToggled() {
        if themeSwitch.isOn {
            overrideUserInterfaceStyle = .dark
        } else {
            overrideUserInterfaceStyle = .light
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
