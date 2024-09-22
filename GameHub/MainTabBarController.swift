import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

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

        // Set titles and system tab bar items
        homeVC.title = "Home"
        libraryVC.title = "Library"
        marketVC.title = "Market"
        profileVC.title = "Profile"

        homeNav.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        libraryNav.tabBarItem = UITabBarItem(title: "Library", image: UIImage(systemName: "books.vertical"), tag: 1)
        marketNav.tabBarItem = UITabBarItem(title: "Market", image: UIImage(systemName: "cart"), tag: 2)
        profileNav.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.circle"), tag: 3)

        // Add navigation controllers to the tab bar
        self.viewControllers = [homeNav, libraryNav, marketNav, profileNav]
    }
}
