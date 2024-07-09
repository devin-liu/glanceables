import Foundation
import UIKit  // Needed for CGSize and CGRect

class WebClipUserDefaultsViewModel {
    static let shared = WebClipUserDefaultsViewModel()  // Singleton instance
    
    private let userDefaultsManager = UserDefaultsManager.shared  // Assuming UserDefaultsManager also uses a singleton pattern
    
    func saveWebViewItems(_ items: [WebClip]) {
        let itemsData = items.map { encodeWebViewItem($0) }
        userDefaultsManager.saveItems(itemsData)
    }
    
    func loadWebViewItems() -> [WebClip] {
        let itemsData = userDefaultsManager.loadItems()
        return itemsData.compactMap { decodeWebViewItem(dict: $0) }
    }
    
    func deleteWebViewItem(_ item: WebClip) {
        let items = loadWebViewItems()
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            userDefaultsManager.deleteItem(at: index)
        }
    }
    
    func updateWebViewItem(_ item: WebClip) {
        var items = loadWebViewItems()
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            let itemData = encodeWebViewItem(item)
            userDefaultsManager.updateItem(itemData, at: index)
        }
    }
    
    private func encodeWebViewItem(_ item: WebClip) -> [String: Any] {
        var dict = [String: Any]()
        dict["id"] = item.id.uuidString
        dict["url"] = item.url.absoluteString
        dict["pageTitle"] = item.pageTitle
        dict["screenshotPath"] = item.screenshotPath
        
        if let clipRect = item.clipRect {
            dict["clipRect"] = [
                "x": clipRect.origin.x,
                "y": clipRect.origin.y,
                "width": clipRect.width,
                "height": clipRect.height
            ]
        }
        
        if let originalSize = item.originalSize {
            dict["originalSize"] = [
                "width": originalSize.width,
                "height": originalSize.height
            ]
        }
        
        return dict
    }
    
    private func decodeWebViewItem(dict: [String: Any]) -> WebClip? {
        guard let idString = dict["id"] as? String,
              let id = UUID(uuidString: idString),
              let urlString = dict["url"] as? String,
              let url = URL(string: urlString) else {
            return nil
        }
        
        let clipRect = decodeRect(dict: dict["clipRect"] as? [String: Any])
        let originalSize = decodeSize(dict: dict["originalSize"] as? [String: Any])
        let screenshotPath = dict["screenshotPath"] as? String
        let pageTitle = dict["pageTitle"] as? String
        
        return WebClip(id: id, url: url, clipRect: clipRect, originalSize: originalSize, screenshotPath: screenshotPath, pageTitle: pageTitle)
    }
    
    private func decodeRect(dict: [String: Any]?) -> CGRect? {
        guard let dict = dict,
              let x = dict["x"] as? CGFloat,
              let y = dict["y"] as? CGFloat,
              let width = dict["width"] as? CGFloat,
              let height = dict["height"] as? CGFloat else {
            return nil
        }
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    private func decodeSize(dict: [String: Any]?) -> CGSize? {
        guard let dict = dict,
              let width = dict["width"] as? CGFloat,
              let height = dict["height"] as? CGFloat else {
            return nil
        }
        return CGSize(width: width, height: height)
    }
}
