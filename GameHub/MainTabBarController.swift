import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Create instances of each view controller
        let homeVC = HomeViewController()
        let libraryVC = LibraryViewController()
        let marketVC = MarketViewController()
        let profileVC = ProfileViewController()

        // Set titles and system tab bar items
        homeVC.title = "Home"
        libraryVC.title = "Library"
        marketVC.title = "Market"
        profileVC.title = "Profile"

        homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        libraryVC.tabBarItem = UITabBarItem(title: "Library", image: UIImage(systemName: "books.vertical"), tag: 1)
        marketVC.tabBarItem = UITabBarItem(title: "Market", image: UIImage(systemName: "cart"), tag: 2)
        profileVC.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.circle"), tag: 3)

        // Add view controllers to the tab bar
        self.viewControllers = [homeVC, libraryVC, marketVC, profileVC]
    }
}
