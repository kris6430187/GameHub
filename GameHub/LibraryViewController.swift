import UIKit

class LibraryViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // Example UI setup
        let libraryLabel = UILabel()
        libraryLabel.text = "Your Game Library"
        libraryLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        libraryLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(libraryLabel)

        // Layout constraints
        NSLayoutConstraint.activate([
            libraryLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            libraryLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
