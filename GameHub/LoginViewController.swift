import UIKit
import FirebaseAuth
import Firebase
import GoogleSignIn

class LoginViewController: UIViewController {

    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let signupButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.addTarget(self, action: #selector(signupTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Forgot Password?", for: .normal)
        button.addTarget(self, action: #selector(forgotPasswordTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let googleSignInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign in with Google", for: .normal)
        button.addTarget(self, action: #selector(googleSignInTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
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

    @objc private func loginTapped() {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Login error: \(error.localizedDescription)")
                self.showAlert(title: "Error", message: error.localizedDescription)
                return
            }
            // Navigate to the main app screen
            self.navigateToMainApp()
        }
    }

    @objc private func signupTapped() {
        let signupVC = SignupViewController()
        navigationController?.pushViewController(signupVC, animated: true)
    }

    @objc private func forgotPasswordTapped() {
        let alertController = UIAlertController(title: "Reset Password", message: "Enter your email to receive password reset instructions.", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Email"
            textField.keyboardType = .emailAddress
        }
        let sendAction = UIAlertAction(title: "Send", style: .default) { _ in
            if let email = alertController.textFields?.first?.text, !email.isEmpty {
                self.sendPasswordReset(to: email)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(sendAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    private func sendPasswordReset(to email: String) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                print("Error sending password reset: \(error.localizedDescription)")
                self.showAlert(title: "Error", message: error.localizedDescription)
                return
            }
            self.showAlert(title: "Success", message: "Password reset email sent.")
        }
    }

    @objc private func googleSignInTapped() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)

        GIDSignIn.sharedInstance.configuration = config
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { signInResult, error in
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
                self.navigateToMainApp()
            }
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func navigateToMainApp() {
        let mainTabBarController = MainTabBarController()
        mainTabBarController.modalPresentationStyle = .fullScreen
        present(mainTabBarController, animated: true, completion: nil)
    }
}
