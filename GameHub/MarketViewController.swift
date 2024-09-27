import UIKit
import WebKit

// Define structs to match the JSON structure of the API responses
struct GameDeal: Decodable {
    let title: String
    let salePrice: String
    let normalPrice: String
    let thumb: String
    let storeID: String
    let metacriticLink: String?
}

struct Store: Decodable {
    let storeID: String
    let storeName: String
}

class MarketViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    private var deals: [GameDeal] = []
    private var stores: [Store] = []
    private let tableView = UITableView()
    private let searchBar = UISearchBar()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupUI()
        fetchStores()
        fetchGameDeals(query: nil)
        
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

    private func setupUI() {
        // Set up the search bar
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)

        // Set up the table view
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(GameDealCell.self, forCellReuseIdentifier: GameDealCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        // Layout constraints
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    func fetchStores() {
        guard let url = URL(string: "https://www.cheapshark.com/api/1.0/stores") else { return }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching stores: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                let stores = try JSONDecoder().decode([Store].self, from: data)
                DispatchQueue.main.async {
                    self.stores = stores
                }
            } catch {
                print("Error decoding stores: \(error.localizedDescription)")
            }
        }
        task.resume()
    }

    func fetchGameDeals(query: String?) {
        var urlString = "https://www.cheapshark.com/api/1.0/deals?sortBy=Price&desc=0&onSale=1"
        if let query = query, !query.isEmpty {
            urlString += "&title=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        }
        
        guard let url = URL(string: urlString) else { return }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                let deals = try JSONDecoder().decode([GameDeal].self, from: data)
                DispatchQueue.main.async {
                    self.deals = deals
                    self.tableView.reloadData()
                }
            } catch {
                print("Error decoding data: \(error.localizedDescription)")
            }
        }
        task.resume()
    }

    // MARK: - Localization
    @objc private func languageChanged() {
        updateLocalizedStrings()
    }

    private func updateLocalizedStrings() {
        searchBar.placeholder = LanguageManager.shared.localizedString(for: "SearchForAGame")
        self.title = LanguageManager.shared.localizedString(for: "Market")
        tableView.reloadData()
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deals.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GameDealCell.identifier, for: indexPath) as? GameDealCell else {
            return UITableViewCell()
        }
        let deal = deals[indexPath.row]
        let storeName = stores.first(where: { $0.storeID == deal.storeID })?.storeName ?? LanguageManager.shared.localizedString(for: "UnknownStore")
        cell.configure(with: deal, storeName: storeName)
        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let deal = deals[indexPath.row]
        guard let metacriticLink = deal.metacriticLink, !metacriticLink.isEmpty else {
            // Show an alert if there's no Metacritic link
            let alert = UIAlertController(title: LanguageManager.shared.localizedString(for: "NoMetacriticLink"),
                                          message: LanguageManager.shared.localizedString(for: "NoMetacriticLinkMessage"),
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: LanguageManager.shared.localizedString(for: "OK"), style: .default))
            present(alert, animated: true)
            return
        }
        
        let fullMetacriticURL = "https://www.metacritic.com" + metacriticLink
        guard let url = URL(string: fullMetacriticURL) else {
            print("Invalid URL: \(fullMetacriticURL)")
            return
        }
        
        let webViewController = WebViewController(url: url)
        navigationController?.pushViewController(webViewController, animated: true)
    }

    // MARK: - UISearchBarDelegate

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        fetchGameDeals(query: searchText)
    }
}

class GameDealCell: UITableViewCell {
    static let identifier = "GameDealCell"

    let titleLabel = UILabel()
    let priceLabel = UILabel()
    let storeLabel = UILabel()
    let gameImageView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        priceLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        storeLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        storeLabel.textColor = .secondaryLabel
        gameImageView.contentMode = .scaleAspectFill
        gameImageView.clipsToBounds = true

        let textStackView = UIStackView(arrangedSubviews: [titleLabel, priceLabel, storeLabel])
        textStackView.axis = .vertical
        textStackView.spacing = 5

        let mainStackView = UIStackView(arrangedSubviews: [gameImageView, textStackView])
        mainStackView.axis = .horizontal
        mainStackView.spacing = 10
        mainStackView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(mainStackView)

        NSLayoutConstraint.activate([
            gameImageView.widthAnchor.constraint(equalToConstant: 60),
            gameImageView.heightAnchor.constraint(equalToConstant: 60),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }

    func configure(with deal: GameDeal, storeName: String) {
        titleLabel.text = deal.title
        priceLabel.text = String(format: LanguageManager.shared.localizedString(for: "PriceFormat"), deal.salePrice, deal.normalPrice)
        storeLabel.text = String(format: LanguageManager.shared.localizedString(for: "StoreFormat"), storeName)
        if let url = URL(string: deal.thumb) {
            // Load image asynchronously
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data {
                    DispatchQueue.main.async {
                        self.gameImageView.image = UIImage(data: data)
                    }
                }
            }.resume()
        }
    }
}
