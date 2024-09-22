import UIKit
import WebKit
import Alamofire
import AlamofireImage

class HomeViewController: UIViewController {

    // MARK: - Properties
    private let logoImageView = UIImageView()
    private let videoPlayerContainer = UIView()
    private var collectionView: UICollectionView!
    private var gameCovers: [HomeCover] = []
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Try these games"
        label.font = UIFont(name: "AvenirNext-Bold", size: 20) // Replace with your custom font
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let clientID = "fhnvgqyhcufns125esnbjl1iqacqxy"
    private let accessToken = "mpfty6g3ugf1m2isb38p547j7v61x8"

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchRandomVideo()
        fetchRandomGameCovers()
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        setupLogoImageView()
        setupVideoPlayerContainer()
        setupTitleLabel()
        setupCollectionView()
    }

    private func setupLogoImageView() {
        logoImageView.image = UIImage(named: "Game-Hub") // Make sure to add your logo to assets
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoImageView)
        
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 200),
            logoImageView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    private func setupVideoPlayerContainer() {
        videoPlayerContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(videoPlayerContainer)
        
        NSLayoutConstraint.activate([
            videoPlayerContainer.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 20),
            videoPlayerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            videoPlayerContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            videoPlayerContainer.heightAnchor.constraint(equalToConstant: 200)
        ])
    }

    private func setupTitleLabel() {
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: videoPlayerContainer.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 120, height: 180)
        layout.minimumInteritemSpacing = 10
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(GameCoverCell.self, forCellWithReuseIdentifier: "GameCoverCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
        collectionView.showsHorizontalScrollIndicator = false
        view.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    // MARK: - API Calls
    private func fetchRandomVideo() {
        let query = "fields name,videos.*; where videos != null; sort popularity desc; limit 50;"
        
        let url = "https://api.igdb.com/v4/games"
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
            "Client-ID": clientID,
            "Accept": "application/json"
        ]

        AF.request(url, method: .post, parameters: [:], encoding: HTTPBodyEncoding(body: query), headers: headers)
            .validate()
            .responseDecodable(of: [HomeGame].self) { [weak self] response in
                switch response.result {
                case .success(let games):
                    if let randomGame = games.randomElement(),
                       let randomVideo = randomGame.videos?.randomElement() {
                        self?.playVideo(withID: randomVideo.videoId)
                    }
                case .failure(let error):
                    print("Error fetching random video: \(error)")
                }
            }
    }

    private func fetchRandomGameCovers() {
        let query = "fields name,cover.*; where cover != null; sort popularity desc; limit 50;"
        
        let url = "https://api.igdb.com/v4/games"
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
            "Client-ID": clientID,
            "Accept": "application/json"
        ]

        AF.request(url, method: .post, parameters: [:], encoding: HTTPBodyEncoding(body: query), headers: headers)
            .validate()
            .responseDecodable(of: [HomeGame].self) { [weak self] response in
                switch response.result {
                case .success(let games):
                    let shuffledGames = games.shuffled()
                    self?.gameCovers = Array(shuffledGames.compactMap { $0.cover }.prefix(10))
                    DispatchQueue.main.async {
                        self?.collectionView.reloadData()
                    }
                case .failure(let error):
                    print("Error fetching random game covers: \(error)")
                }
            }
    }

    private func playVideo(withID videoId: String) {
        let videoURLString = "https://www.youtube.com/embed/\(videoId)"
        
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsInlineMediaPlayback = true
        webConfiguration.mediaTypesRequiringUserActionForPlayback = []
        
        let webView = WKWebView(frame: videoPlayerContainer.bounds, configuration: webConfiguration)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        if let url = URL(string: videoURLString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        
        videoPlayerContainer.subviews.forEach { $0.removeFromSuperview() }
        videoPlayerContainer.addSubview(webView)
    }
}

// MARK: - UICollectionViewDataSource
extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gameCovers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GameCoverCell", for: indexPath) as! GameCoverCell
        let cover = gameCovers[indexPath.item]
        let imageURL = "https://images.igdb.com/igdb/image/upload/t_cover_big/\(cover.imageId).jpg"
        cell.configure(with: URL(string: imageURL)!)
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension HomeViewController: UICollectionViewDelegate {
    // Implement any delegate methods if needed
}

// MARK: - GameCoverCell
class GameCoverCell: UICollectionViewCell {
    private let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupImageView() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func configure(with url: URL) {
        imageView.af.setImage(withURL: url, placeholderImage: UIImage(systemName: "photo"))
    }
}

// MARK: - Additional Structs
struct HomeVideo: Codable {
    let id: Int
    let videoId: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case videoId = "video_id"
    }
}

struct HomeCover: Codable {
    let id: Int
    let imageId: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case imageId = "image_id"
    }
}

struct HomeGame: Codable {
    let id: Int
    let name: String
    let cover: HomeCover?
    let videos: [HomeVideo]?
}
