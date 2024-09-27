import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: - UI Elements
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 60
        imageView.layer.borderWidth = 3
        imageView.layer.borderColor = UIColor.systemBlue.cgColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    private let changePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Change Photo", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .gray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let settingsLabel: UILabel = {
        let label = UILabel()
        label.text = "Settings"
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let themeLabel: UILabel = {
        let label = UILabel()
        label.text = "Dark Mode"
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let themeSwitch: UISwitch = {
        let themeSwitch = UISwitch()
        themeSwitch.translatesAutoresizingMaskIntoConstraints = false
        return themeSwitch
    }()

    private let languageLabel: UILabel = {
        let label = UILabel()
        label.text = "Language"
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let languageSelector: UISegmentedControl = {
        let items = [LanguageManager.shared.localizedString(for: "English"),
                     LanguageManager.shared.localizedString(for: "Thai")]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
    }()

    private let submitFeedbackButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Submit Feedback", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Logout", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        loadUserProfile()
        setupLanguageSelector()
        setupThemeSwitch()
        updateLocalizedStrings()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(changeProfilePicture))
        profileImageView.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(languageChanged),
                                               name: LanguageManager.languageChangedNotification,
                                               object: nil)
    }

    // MARK: - Setup Methods
    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(profileImageView)
        contentView.addSubview(changePhotoButton)
        contentView.addSubview(nameLabel)
        contentView.addSubview(emailLabel)
        contentView.addSubview(settingsLabel)
        contentView.addSubview(themeLabel)
        contentView.addSubview(themeSwitch)
        contentView.addSubview(languageLabel)
        contentView.addSubview(languageSelector)
        contentView.addSubview(submitFeedbackButton)
        contentView.addSubview(logoutButton)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            profileImageView.widthAnchor.constraint(equalToConstant: 120),
            profileImageView.heightAnchor.constraint(equalToConstant: 120),

            changePhotoButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            changePhotoButton.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),

            nameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            nameLabel.topAnchor.constraint(equalTo: changePhotoButton.bottomAnchor, constant: 16),

            emailLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),

            settingsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            settingsLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 32),

            themeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            themeLabel.topAnchor.constraint(equalTo: settingsLabel.bottomAnchor, constant: 16),

            themeSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            themeSwitch.centerYAnchor.constraint(equalTo: themeLabel.centerYAnchor),

            languageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            languageLabel.topAnchor.constraint(equalTo: themeLabel.bottomAnchor, constant: 24),

            languageSelector.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            languageSelector.centerYAnchor.constraint(equalTo: languageLabel.centerYAnchor),
            languageSelector.widthAnchor.constraint(equalToConstant: 150),

            submitFeedbackButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            submitFeedbackButton.topAnchor.constraint(equalTo: languageSelector.bottomAnchor, constant: 32),
            submitFeedbackButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.8),
            submitFeedbackButton.heightAnchor.constraint(equalToConstant: 44),

            logoutButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoutButton.topAnchor.constraint(equalTo: submitFeedbackButton.bottomAnchor, constant: 16),
            logoutButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.8),
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])

        changePhotoButton.addTarget(self, action: #selector(changeProfilePicture), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        submitFeedbackButton.addTarget(self, action: #selector(submitFeedbackTapped), for: .touchUpInside)
        themeSwitch.addTarget(self, action: #selector(themeSwitchToggled), for: .valueChanged)
        languageSelector.addTarget(self, action: #selector(languageSelectionChanged), for: .valueChanged)
    }

    private func setupLanguageSelector() {
        languageSelector.selectedSegmentIndex = LanguageManager.shared.currentLanguage == .english ? 0 : 1
    }

    private func setupThemeSwitch() {
        themeSwitch.isOn = ThemeManager.shared.currentTheme == .dark
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

    // MARK: - Action Methods
    @objc private func changeProfilePicture() {
        let alert = UIAlertController(title: LanguageManager.shared.localizedString(for: "Profile Picture"),
                                      message: LanguageManager.shared.localizedString(for: "Choose a source"),
                                      preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: LanguageManager.shared.localizedString(for: "Camera"), style: .default, handler: { _ in
            self.presentImagePicker(sourceType: .camera)
        }))
        alert.addAction(UIAlertAction(title: LanguageManager.shared.localizedString(for: "Photo Library"), style: .default, handler: { _ in
            self.presentImagePicker(sourceType: .photoLibrary)
        }))
        alert.addAction(UIAlertAction(title: LanguageManager.shared.localizedString(for: "Cancel"), style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
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
        let alertController = UIAlertController(title: LanguageManager.shared.localizedString(for: "Submit Feedback"),
                                                message: LanguageManager.shared.localizedString(for: "Please enter your feedback below:"),
                                                preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = LanguageManager.shared.localizedString(for: "Your feedback here")
        }
        
        let submitAction = UIAlertAction(title: LanguageManager.shared.localizedString(for: "Submit"), style: .default) { [weak self] _ in
            guard let feedback = alertController.textFields?.first?.text, !feedback.isEmpty else {
                self?.showAlert(title: "Error", message: "Please enter your feedback.")
                return
            }
            
            self?.saveFeedbackToFirebase(feedback)
        }
        
        let cancelAction = UIAlertAction(title: LanguageManager.shared.localizedString(for: "Cancel"), style: .cancel, handler: nil)
        
        alertController.addAction(submitAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }

    @objc private func themeSwitchToggled() {
        ThemeManager.shared.currentTheme = themeSwitch.isOn ? .dark : .light
    }

    @objc private func languageSelectionChanged() {
        let selectedLanguage: Language = languageSelector.selectedSegmentIndex == 0 ? .english : .thai
        LanguageManager.shared.currentLanguage = selectedLanguage
        // This will trigger the languageChanged notification
    }

    @objc private func languageChanged() {
        updateLocalizedStrings()
        // Optionally restart the app or refresh the UI as needed
    }

    // MARK: - Helper Methods
    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else { return }
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        present(picker, animated: true, completion: nil)
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

    private func updateLocalizedStrings() {
        logoutButton.setTitle(LanguageManager.shared.localizedString(for: "Logout"), for: .normal)
        submitFeedbackButton.setTitle(LanguageManager.shared.localizedString(for: "Submit Feedback"), for: .normal)
        
        languageSelector.setTitle(LanguageManager.shared.localizedString(for: "English"), forSegmentAt: 0)
        languageSelector.setTitle(LanguageManager.shared.localizedString(for: "Thai"), forSegmentAt: 1)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: LanguageManager.shared.localizedString(for: title),
                                      message: LanguageManager.shared.localizedString(for: message),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: LanguageManager.shared.localizedString(for: "OK"), style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    // MARK: - UIImagePickerControllerDelegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[.originalImage] as? UIImage else { return }
        profileImageView.image = selectedImage
        uploadProfileImage(selectedImage)
    }
}
