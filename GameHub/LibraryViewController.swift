import UIKit
import Alamofire

struct Game: Codable {
    let id: Int
    let name: String
    let category: Int
    let url: String
}

struct HTTPBodyEncoding: ParameterEncoding {
    let body: String
    
    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        request.httpBody = body.data(using: .utf8)
        return request
    }
}

class LibraryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let tableView = UITableView()
    private var games: [Game] = []
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    private let clientID = "fhnvgqyhcufns125esnbjl1iqacqxy"
    private let accessToken = "mpfty6g3ugf1m2isb38p547j7v61x8"

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchGames()
        
        // Adjust table view content inset to account for tab bar
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: tabBarController?.tabBar.frame.height ?? 0, right: 0)
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        let libraryLabel = UILabel()
        libraryLabel.text = "Your Game Library"
        libraryLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        libraryLabel.translatesAutoresizingMaskIntoConstraints = false

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "GameCell")

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true

        view.addSubview(libraryLabel)
        view.addSubview(tableView)
        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            libraryLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            libraryLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            tableView.topAnchor.constraint(equalTo: libraryLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func fetchGames() {
        activityIndicator.startAnimating()
        
        let url = "https://api.igdb.com/v4/games"
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
            "Client-ID": clientID,
            "Accept": "application/json"
        ]
        
        let body = "fields id, category, name, url; limit 20;"

        AF.request(url, method: .post, parameters: [:], encoding: HTTPBodyEncoding(body: body), headers: headers)
            .validate()
            .responseDecodable(of: [Game].self) { [weak self] response in
                self?.activityIndicator.stopAnimating()
                
                switch response.result {
                case .success(let games):
                    self?.games = games
                    self?.tableView.reloadData()
                case .failure(let error):
                    print("Error: \(error)")
                    self?.showAlert(message: "Failed to fetch games. Please try again.")
                }
            }
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GameCell", for: indexPath)
        let game = games[indexPath.row]
        
        cell.textLabel?.text = game.name
        cell.detailTextLabel?.text = "Category: \(game.category)"
        
        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let game = games[indexPath.row]
        print("Selected game: \(game.name), URL: \(game.url)")
        // Here you could open the game's URL or navigate to a detail view
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
