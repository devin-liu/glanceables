import Foundation
import UIKit  // Needed for CGSize and CGRect

class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    private let urlsKey = "savedURLs"

    func saveWebViewItems(_ items: [WebViewItem]) {
        let itemsData = items.map { item -> [String: Any] in
            var dict = [String: Any]()
            dict["url"] = item.url.absoluteString
            dict["id"] = item.id.uuidString  // Save the UUID as a string

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

            if let screenshotPath = item.screenshotPath {
                dict["screenshotPath"] = screenshotPath
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
                  let idString = dict["id"] as? String,
                  let id = UUID(uuidString: idString) else {
                return nil
            }

            let clipRect: CGRect? = {
                if let clipDict = dict["clipRect"] as? [String: CGFloat],
                   let x = clipDict["x"],
                   let y = clipDict["y"],
                   let width = clipDict["width"],
                   let height = clipDict["height"] {
                    return CGRect(x: x, y: y, width: width, height: height)
                }
                return nil
            }()
            
            let originalSize: CGSize? = {
                if let sizeDict = dict["originalSize"] as? [String: CGFloat],
                   let width = sizeDict["width"],
                   let height = sizeDict["height"] {
                    return CGSize(width: width, height: height)
                }
                return nil
            }()

            let screenshotPath = dict["screenshotPath"] as? String

            return WebViewItem(id: id, url: url, clipRect: clipRect, originalSize: originalSize, screenshotPath: screenshotPath)
        }
    }
}
