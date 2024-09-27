import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViewControllers()
        
        // Add observer for language changes
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(languageChanged),
                                               name: LanguageManager.languageChangedNotification,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupViewControllers() {
        // Create instances of each view controller
        let homeVC = HomeViewController()
        let libraryVC = LibraryViewController()
        let marketVC = MarketViewController()
        let profileVC = ProfileViewController()

        // Wrap each VC in a UINavigationController
        let homeNav = UINavigationController(rootViewController: homeVC)
        let libraryNav = UINavigationController(rootViewController: libraryVC)
        let marketNav = UINavigationController(rootViewController: marketVC)
        let profileNav = UINavigationController(rootViewController: profileVC)

        // Set titles using localized strings
        homeVC.title = LanguageManager.shared.localizedString(for: "Home")
        libraryVC.title = LanguageManager.shared.localizedString(for: "Library")
        marketVC.title = LanguageManager.shared.localizedString(for: "Market")
        profileVC.title = LanguageManager.shared.localizedString(for: "Profile")

        // Set tab bar items using localized strings
        homeNav.tabBarItem = UITabBarItem(title: LanguageManager.shared.localizedString(for: "Home"),
                                          image: UIImage(systemName: "house"), tag: 0)
        libraryNav.tabBarItem = UITabBarItem(title: LanguageManager.shared.localizedString(for: "Library"),
                                             image: UIImage(systemName: "books.vertical"), tag: 1)
        marketNav.tabBarItem = UITabBarItem(title: LanguageManager.shared.localizedString(for: "Market"),
                                            image: UIImage(systemName: "cart"), tag: 2)
        profileNav.tabBarItem = UITabBarItem(title: LanguageManager.shared.localizedString(for: "Profile"),
                                             image: UIImage(systemName: "person.circle"), tag: 3)

        // Add navigation controllers to the tab bar
        self.viewControllers = [homeNav, libraryNav, marketNav, profileNav]
    }
    
    @objc private func languageChanged() {
        // Update tab bar item titles
        viewControllers?.forEach { viewController in
            if let navController = viewController as? UINavigationController {
                switch navController.viewControllers.first {
                case is HomeViewController:
                    navController.tabBarItem.title = LanguageManager.shared.localizedString(for: "Home")
                case is LibraryViewController:
                    navController.tabBarItem.title = LanguageManager.shared.localizedString(for: "Library")
                case is MarketViewController:
                    navController.tabBarItem.title = LanguageManager.shared.localizedString(for: "Market")
                case is ProfileViewController:
                    navController.tabBarItem.title = LanguageManager.shared.localizedString(for: "Profile")
                default:
                    break
                }
                
                // Update the title of the root view controller
                navController.viewControllers.first?.title = navController.tabBarItem.title
            }
        }
    }
}
