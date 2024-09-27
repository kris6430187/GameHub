import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {
    private var webView: WKWebView!
    private var url: URL
    
    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let request = URLRequest(url: url)
        webView.load(request)
        
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: webView, action: #selector(webView.goBack))
        let forwardButton = UIBarButtonItem(image: UIImage(systemName: "chevron.forward"), style: .plain, target: webView, action: #selector(webView.goForward))
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
        
        navigationItem.rightBarButtonItems = [refreshButton, forwardButton, backButton]
        applyTheme()
        
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            applyTheme() 
        }
    }
    
    func applyTheme() {
        if traitCollection.userInterfaceStyle == .dark {
            webView.backgroundColor = .black
            customizeNavigationBar(for: .dark)
        } else {
            webView.backgroundColor = .white
            customizeNavigationBar(for: .light)
        }
    }
    
    private func customizeNavigationBar(for theme: UIUserInterfaceStyle) {
        if let navigationBar = navigationController?.navigationBar {
            let appearance = UINavigationBarAppearance()
            switch theme {
            case .dark:
                appearance.backgroundColor = .black
                appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
                appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            case .light, .unspecified:
                appearance.backgroundColor = .white
                appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
                appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
            @unknown default:
                break
            }
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
            navigationBar.compactAppearance = appearance
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
    }
}
