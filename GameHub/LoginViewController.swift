import UIKit
import FirebaseAuth
import Firebase
import GoogleSignIn

class LoginViewController: UIViewController {

    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
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

    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let signupButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(signupTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(forgotPasswordTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let googleSignInButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(googleSignInTapped), for: .touchUpInside)
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
        view.addSubview(loginButton)
        view.addSubview(signupButton)
        view.addSubview(forgotPasswordButton)
        view.addSubview(googleSignInButton)

        NSLayoutConstraint.activate([
            emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
            emailTextField.widthAnchor.constraint(equalToConstant: 250),

            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.widthAnchor.constraint(equalToConstant: 250),

            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),

            signupButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signupButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 10),

            forgotPasswordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            forgotPasswordButton.topAnchor.constraint(equalTo: signupButton.bottomAnchor, constant: 10),

            googleSignInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            googleSignInButton.topAnchor.constraint(equalTo: forgotPasswordButton.bottomAnchor, constant: 20)
        ])
    }

    // MARK: - Localization
    @objc private func languageChanged() {
        updateLocalizedStrings()
    }

    private func updateLocalizedStrings() {
        emailTextField.placeholder = LanguageManager.shared.localizedString(for: "Email")
        passwordTextField.placeholder = LanguageManager.shared.localizedString(for: "Password")
        loginButton.setTitle(LanguageManager.shared.localizedString(for: "Login"), for: .normal)
        signupButton.setTitle(LanguageManager.shared.localizedString(for: "SignUp"), for: .normal)
        forgotPasswordButton.setTitle(LanguageManager.shared.localizedString(for: "ForgotPassword"), for: .normal)
        googleSignInButton.setTitle(LanguageManager.shared.localizedString(for: "SignInWithGoogle"), for: .normal)
        self.title = LanguageManager.shared.localizedString(for: "Login")
    }

    @objc private func loginTapped() {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                print("Login error: \(error.localizedDescription)")
                self?.showAlert(title: LanguageManager.shared.localizedString(for: "Error"), message: error.localizedDescription)
                return
            }
            // Navigate to the main app screen
            self?.navigateToMainApp()
        }
    }

    @objc private func signupTapped() {
        let signupVC = SignupViewController()
        navigationController?.pushViewController(signupVC, animated: true)
    }

    @objc private func forgotPasswordTapped() {
        let alertController = UIAlertController(title: LanguageManager.shared.localizedString(for: "ResetPassword"),
                                                message: LanguageManager.shared.localizedString(for: "EnterEmailForReset"),
                                                preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = LanguageManager.shared.localizedString(for: "Email")
            textField.keyboardType = .emailAddress
        }
        let sendAction = UIAlertAction(title: LanguageManager.shared.localizedString(for: "Send"), style: .default) { [weak self] _ in
            if let email = alertController.textFields?.first?.text, !email.isEmpty {
                self?.sendPasswordReset(to: email)
            }
        }
        let cancelAction = UIAlertAction(title: LanguageManager.shared.localizedString(for: "Cancel"), style: .cancel, handler: nil)
        alertController.addAction(sendAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    private func sendPasswordReset(to email: String) {
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            if let error = error {
                print("Error sending password reset: \(error.localizedDescription)")
                self?.showAlert(title: LanguageManager.shared.localizedString(for: "Error"), message: error.localizedDescription)
                return
            }
            self?.showAlert(title: LanguageManager.shared.localizedString(for: "Success"),
                            message: LanguageManager.shared.localizedString(for: "PasswordResetEmailSent"))
        }
    }

    @objc private func googleSignInTapped() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)

        GIDSignIn.sharedInstance.configuration = config
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] signInResult, error in
            if let error = error {
                print("Google Sign-In error: \(error.localizedDescription)")
                return
            }

            guard let user = signInResult?.user,
                  let idToken = user.idToken?.tokenString else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase Sign-In error: \(error.localizedDescription)")
                    return
                }
                // Navigate to the main app screen
                self?.navigateToMainApp()
            }
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: LanguageManager.shared.localizedString(for: "OK"), style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func navigateToMainApp() {
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.showMainInterface()
        }
    }
}
