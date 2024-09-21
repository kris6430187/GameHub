import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // Example UI setup
        let welcomeLabel = UILabel()
        welcomeLabel.text = "Welcome to GameHub!"
        welcomeLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(welcomeLabel)

        // Layout constraints
        NSLayoutConstraint.activate([
            welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            welcomeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
