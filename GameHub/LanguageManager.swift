import Foundation
import UIKit

enum Language: String {
    case english = "en"
    case thai = "th"
}

class LanguageManager {
    static let shared = LanguageManager()
    
    static let languageChangedNotification = Notification.Name("LanguageChangedNotification")
    
    var currentLanguage: Language {
        get {
            if let languageCode = UserDefaults.standard.string(forKey: "SelectedLanguage"),
               let language = Language(rawValue: languageCode) {
                return language
            }
            return .english // Default to English
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "SelectedLanguage")
            UserDefaults.standard.synchronize()
            updateLanguage(to: newValue)
            NotificationCenter.default.post(name: LanguageManager.languageChangedNotification, object: nil)
        }
    }
    
    func localizedString(for key: String) -> String {
        let path = Bundle.main.path(forResource: currentLanguage.rawValue, ofType: "lproj")
        let bundle = Bundle(path: path!)
        return NSLocalizedString(key, tableName: nil, bundle: bundle!, value: "", comment: "")
    }
    
    private func updateLanguage(to language: Language) {
        UserDefaults.standard.set([language.rawValue], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }
}
