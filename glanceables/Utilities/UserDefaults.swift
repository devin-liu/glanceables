import Foundation
import UIKit

import Foundation

class UserDefaultsManager {
    static let urlsKey = "savedURLs"
    
    static func saveWebClips(_ itemsData: [[String: Any]]) {
        UserDefaults.standard.set(itemsData, forKey: urlsKey)
    }
    
    static func loadWebClips() -> [[String: Any]] {
        return UserDefaults.standard.array(forKey: urlsKey) as? [[String: Any]] ?? []
    }
    
    static func deleteWebClip(at index: Int) {
        var items = loadWebClips()
        items.remove(at: index)
        saveWebClips(items)
    }
    
    static func updateWebClip(_ itemData: [String: Any], at index: Int) {
        var items = loadWebClips()
        items[index] = itemData
        saveWebClips(items)
    }
}
