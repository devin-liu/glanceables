import Foundation

class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    private let urlsKey = "savedURLs"

    func saveURLs(_ urls: [String]) {
        UserDefaults.standard.set(urls, forKey: urlsKey)
    }

    func loadURLs() -> [String] {
        UserDefaults.standard.stringArray(forKey: urlsKey) ?? []
    }
}
