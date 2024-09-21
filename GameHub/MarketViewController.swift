import UIKit

class MarketViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // Example UI setup
        let marketLabel = UILabel()
        marketLabel.text = "Browse the Game Market"
        marketLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        marketLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(marketLabel)

        // Layout constraints
        NSLayoutConstraint.activate([
            marketLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            marketLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
