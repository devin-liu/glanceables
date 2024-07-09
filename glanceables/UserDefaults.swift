import Foundation
import UIKit  // Needed for CGSize and CGRect

import Foundation

class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    private let urlsKey = "savedURLs"
    
    func saveItems(_ itemsData: [[String: Any]]) {
        UserDefaults.standard.set(itemsData, forKey: urlsKey)
    }
    
    func loadItems() -> [[String: Any]] {
        return UserDefaults.standard.array(forKey: urlsKey) as? [[String: Any]] ?? []
    }
    
    func deleteItem(at index: Int) {
        var items = loadItems()
        items.remove(at: index)
        saveItems(items)
    }
    
    func updateItem(_ itemData: [String: Any], at index: Int) {
        var items = loadItems()
        items[index] = itemData
        saveItems(items)
    }
}
