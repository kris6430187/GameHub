import UIKit
import FirebaseAuth
import Firebase
import GoogleSignIn

class LoginViewController: UIViewController {

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

    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        // Set your app logo here
        imageView.image = UIImage(named: "AppLogo")
        return imageView
    }()

    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .none
        textField.backgroundColor = .systemGray6
        textField.layer.cornerRadius = 8
        textField.autocapitalizationType = .none
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        textField.leftViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .none
        textField.backgroundColor = .systemGray6
        textField.layer.cornerRadius = 8
        textField.isSecureTextEntry = true
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        textField.leftViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let signupButton: UIButton = {
            let button = UIButton(type: .system)
            button.backgroundColor = .systemGreen
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 8
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
        button.backgroundColor = .white
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemGray4.cgColor
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(googleSignInTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(languageChanged),
                                               name: LanguageManager.languageChangedNotification,
                                               object: nil)
        
        updateLocalizedStrings()
        setupKeyboardDismissal()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [logoImageView, emailTextField, passwordTextField, loginButton, signupButton, forgotPasswordButton, googleSignInButton].forEach { contentView.addSubview($0) }

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

            logoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            logoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 120),
            logoImageView.heightAnchor.constraint(equalToConstant: 120),

            emailTextField.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 40),
            emailTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 50),

            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),

            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 30),
            loginButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            loginButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            loginButton.heightAnchor.constraint(equalToConstant: 50),

            signupButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20),
            signupButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            signupButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            signupButton.heightAnchor.constraint(equalToConstant: 50),

            forgotPasswordButton.topAnchor.constraint(equalTo: signupButton.bottomAnchor, constant: 10),
            forgotPasswordButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            googleSignInButton.topAnchor.constraint(equalTo: forgotPasswordButton.bottomAnchor, constant: 30),
            googleSignInButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            googleSignInButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            googleSignInButton.heightAnchor.constraint(equalToConstant: 50),
            googleSignInButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }

    private func setupKeyboardDismissal() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
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
