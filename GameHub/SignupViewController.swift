import UIKit
import FirebaseAuth

class SignupViewController: UIViewController {

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
        imageView.image = UIImage(named: "AppLogo")
        return imageView
    }()

    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .none
        textField.backgroundColor = .systemGray6
        textField.layer.cornerRadius = 8
        textField.autocapitalizationType = .none
        textField.keyboardType = .emailAddress
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

    private let signupButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(signupTapped), for: .touchUpInside)
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
        
        [logoImageView, emailTextField, passwordTextField, signupButton].forEach { contentView.addSubview($0) }

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

            signupButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 30),
            signupButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            signupButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            signupButton.heightAnchor.constraint(equalToConstant: 50),
            signupButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }

    private func updateLocalizedStrings() {
        emailTextField.placeholder = LanguageManager.shared.localizedString(for: "Email")
        passwordTextField.placeholder = LanguageManager.shared.localizedString(for: "Password")
        signupButton.setTitle(LanguageManager.shared.localizedString(for: "SignUp"), for: .normal)
        self.title = LanguageManager.shared.localizedString(for: "SignUp")
    }

    private func setupKeyboardDismissal() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func languageChanged() {
        updateLocalizedStrings()
    }

    @objc private func signupTapped() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: LanguageManager.shared.localizedString(for: "Error"),
                      message: LanguageManager.shared.localizedString(for: "FillAllFields"))
            return
        }
        
        if !isValidEmail(email) {
            showAlert(title: LanguageManager.shared.localizedString(for: "Error"),
                      message: LanguageManager.shared.localizedString(for: "InvalidEmail"))
            return
        }
        
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
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        let passwordRegEx = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z\\d]{8,}$"
        let passwordPred = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        return passwordPred.evaluate(with: password)
    }
}
