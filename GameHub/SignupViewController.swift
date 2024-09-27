import UIKit
import FirebaseAuth

class SignupViewController: UIViewController {

    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.keyboardType = .emailAddress
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let signupButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(signupTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        
        // Add observer for language changes
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(languageChanged),
                                               name: LanguageManager.languageChangedNotification,
                                               object: nil)
        
        updateLocalizedStrings()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupLayout() {
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(signupButton)

        NSLayoutConstraint.activate([
            emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            emailTextField.widthAnchor.constraint(equalToConstant: 250),

            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.widthAnchor.constraint(equalToConstant: 250),

            signupButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signupButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20)
        ])
    }

    // MARK: - Localization
    @objc private func languageChanged() {
        updateLocalizedStrings()
    }

    private func updateLocalizedStrings() {
        emailTextField.placeholder = LanguageManager.shared.localizedString(for: "Email")
        passwordTextField.placeholder = LanguageManager.shared.localizedString(for: "Password")
        signupButton.setTitle(LanguageManager.shared.localizedString(for: "SignUp"), for: .normal)
        self.title = LanguageManager.shared.localizedString(for: "SignUp")
    }

    @objc private func signupTapped() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: LanguageManager.shared.localizedString(for: "Error"),
                      message: LanguageManager.shared.localizedString(for: "FillAllFields"))
            return
        }
        
        // Validate email
        if !isValidEmail(email) {
            showAlert(title: LanguageManager.shared.localizedString(for: "Error"),
                      message: LanguageManager.shared.localizedString(for: "InvalidEmail"))
            return
        }
        
        // Validate password
        if !isValidPassword(password) {
            showAlert(title: LanguageManager.shared.localizedString(for: "Error"),
                      message: LanguageManager.shared.localizedString(for: "InvalidPassword"))
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                print("Signup error: \(error.localizedDescription)")
                self?.showAlert(title: LanguageManager.shared.localizedString(for: "Error"), message: error.localizedDescription)
                return
            }
            // Navigate to the main app screen
            self?.navigateToMainApp()
        }
    }

    private func navigateToMainApp() {
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.showMainInterface()
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: LanguageManager.shared.localizedString(for: "OK"), style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Validation
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        // Password should be at least 8 characters long and contain at least one uppercase letter, one lowercase letter, and one number
        let passwordRegEx = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z\\d]{8,}$"
        let passwordPred = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        return passwordPred.evaluate(with: password)
    }
}
