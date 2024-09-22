import UIKit

// Define structs to match the JSON structure of the API responses
struct GameDeal: Decodable {
    let title: String
    let salePrice: String
    let normalPrice: String
    let thumb: String
    let storeID: String
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

        // Set up the search bar
        searchBar.delegate = self
        searchBar.placeholder = "Search for a game"
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

        // Fetch stores and initial game deals
        fetchStores()
        fetchGameDeals(query: nil)
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
        var urlString = "https://www.cheapshark.com/api/1.0/deals"
        if let query = query, !query.isEmpty {
            urlString += "?title=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
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

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deals.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GameDealCell.identifier, for: indexPath) as? GameDealCell else {
            return UITableViewCell()
        }
        let deal = deals[indexPath.row]
        let storeName = stores.first(where: { $0.storeID == deal.storeID })?.storeName ?? "Unknown Store"
        cell.configure(with: deal, storeName: storeName)
        return cell
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
        priceLabel.text = "$\(deal.salePrice) (was $\(deal.normalPrice))"
        storeLabel.text = "Store: \(storeName)"
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
