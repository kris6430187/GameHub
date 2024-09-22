import UIKit
import Alamofire
import AlamofireImage

struct Game: Codable {
    let id: Int
    let name: String
    let url: String
    let cover: Cover?
    let summary: String?
    let first_release_date: Int?
}

struct Cover: Codable {
    let id: Int
    let url: String?
}

class GameCell: UITableViewCell {
    let gameImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(gameImageView)
        contentView.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            gameImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            gameImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            gameImageView.widthAnchor.constraint(equalToConstant: 80),
            gameImageView.heightAnchor.constraint(equalToConstant: 100),
            
            nameLabel.leadingAnchor.constraint(equalTo: gameImageView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}

class LibraryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    private let tableView = UITableView()
    private let searchBar = UISearchBar()
    private var games: [Game] = []
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    private var searchWorkItem: DispatchWorkItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchPopularGames()
        
        // Adjust table view content inset to account for tab bar
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: tabBarController?.tabBar.frame.height ?? 0, right: 0)
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        let libraryLabel = UILabel()
        libraryLabel.text = "Browse Game Library"
        libraryLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        libraryLabel.translatesAutoresizingMaskIntoConstraints = false

        searchBar.placeholder = "Search games"
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(GameCell.self, forCellReuseIdentifier: "GameCell")
        tableView.rowHeight = 120 // Adjusted row height

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true

        view.addSubview(libraryLabel)
        view.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            libraryLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            libraryLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            searchBar.topAnchor.constraint(equalTo: libraryLabel.bottomAnchor, constant: 10),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func fetchPopularGames() {
        fetchGames(query: "fields id, name, url, cover.*; where category = 0 & (status = 0 | status = null) & cover != null; sort popularity desc; limit 50;")
    }

    private func fetchGames(query: String) {
        activityIndicator.startAnimating()
        
        IGDBService.shared.fetchGames(with: query) { [weak self] result in
            self?.activityIndicator.stopAnimating()
            
            switch result {
            case .success(let games):
                self?.games = games
                self?.tableView.reloadData()
            case .failure(let error):
                print("Error: \(error)")
                self?.showAlert(message: "Failed to fetch games. Please try again.")
            }
        }
    }

    private func searchGames(with searchText: String) {
        let query = """
        search "\(searchText)";
        fields id, name, url, cover.*;
        where category = 0 & (status = 0 | status = null) & cover != null;
        limit 50;
        """
        fetchGames(query: query)
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GameCell", for: indexPath) as? GameCell else {
            fatalError("Unable to dequeue GameCell")
        }
        
        let game = games[indexPath.row]
        
        cell.nameLabel.text = game.name
        
        if let coverURL = game.cover?.url {
            let imageURL = "https:" + coverURL.replacingOccurrences(of: "t_thumb", with: "t_cover_small")
            cell.gameImageView.af.setImage(withURL: URL(string: imageURL)!, placeholderImage: UIImage(systemName: "photo"))
        }
        
        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let game = games[indexPath.row]
        if let url = URL(string: game.url) {
            let webViewController = WebViewController(url: url)
            navigationController?.pushViewController(webViewController, animated: true)
        } else {
            showAlert(message: "Invalid game URL")
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - UISearchBarDelegate

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchWorkItem?.cancel()

        if searchText.isEmpty {
            fetchPopularGames()
            return
        }

        let workItem = DispatchWorkItem { [weak self] in
            self?.searchGames(with: searchText)
        }

        searchWorkItem = workItem

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        fetchPopularGames()
    }
}
