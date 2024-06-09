import Foundation
import UIKit  // Needed for CGRect

// Extend UserDefaultsManager to handle complex types
class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    private let urlsKey = "savedURLs"

    func saveWebViewItems(_ items: [WebViewItem]) {
        let itemsData = items.map { item -> [String: Any] in
            var dict = [String: Any]()
            dict["url"] = item.url.absoluteString
            if let clipRect = item.clipRect {
                dict["clipRect"] = [
                    "x": clipRect.origin.x,
                    "y": clipRect.origin.y,
                    "width": clipRect.width,
                    "height": clipRect.height
                ]
            }
            return dict
        }
        UserDefaults.standard.set(itemsData, forKey: urlsKey)
    }

    func loadWebViewItems() -> [WebViewItem] {
        guard let dataArray = UserDefaults.standard.array(forKey: urlsKey) as? [[String: Any]] else {
            return []
        }

        return dataArray.compactMap { dict in
            guard let urlString = dict["url"] as? String,
                  let url = URL(string: urlString),
                  let clipDict = dict["clipRect"] as? [String: Double],
                  let x = clipDict["x"],
                  let y = clipDict["y"],
                  let width = clipDict["width"],
                  let height = clipDict["height"] else {
                return nil
            }
            let clipRect = CGRect(x: x, y: y, width: width, height: height)
            return WebViewItem(id: UUID(), url: url, clipRect: clipRect)
        }
    }
}
