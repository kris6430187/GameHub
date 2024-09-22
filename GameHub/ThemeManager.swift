import UIKit

class ThemeManager {
    static let shared = ThemeManager()
    
    private let defaults = UserDefaults.standard
    private let themeKey = "AppTheme"
    
    var currentTheme: UIUserInterfaceStyle {
        get {
            return UIUserInterfaceStyle(rawValue: defaults.integer(forKey: themeKey)) ?? .unspecified
        }
        set {
            defaults.set(newValue.rawValue, forKey: themeKey)
            applyTheme(newValue)
        }
    }
    
    private init() {}
    
    func applyTheme(_ theme: UIUserInterfaceStyle) {
        UIApplication.shared.windows.forEach { window in
            window.overrideUserInterfaceStyle = theme
        }
    }
    
    func applyCurrentTheme() {
        applyTheme(currentTheme)
    }
}
