import Foundation
import UIKit  // Needed for CGSize and CGRect

class WebClipUserDefaultsRepository: WebClipRepositoryProtocol {
    static let shared = WebClipUserDefaultsRepository()
    private let userDefaults = UserDefaults.standard
    private let webClipKey = "savedURLs"
    
    // Load all WebClips from UserDefaults.
    func loadWebClips() -> [WebClip] {
        let itemsData = UserDefaults.standard.array(forKey: webClipKey) as? [[String: Any]] ?? []
        return itemsData.compactMap { decodeWebViewItem(dict: $0) }
    }
    
    // Save an array of WebClips to UserDefaults.
    func saveWebClips(_ webClips: [WebClip]) {
        let itemsData = webClips.map { encodeWebViewItem($0) }
        UserDefaults.standard.set(itemsData, forKey: webClipKey)
    }
    
    // Delete a specific WebClip from UserDefaults.
    func deleteWebClip(_ webClip: WebClip) {
        var webClips = loadWebClips()
        if let index = webClips.firstIndex(where: { $0.id == webClip.id }) {
            webClips.remove(at: index)
            saveWebClips(webClips)
        }
    }
    
    // Update a specific WebClip in UserDefaults.
    func updateWebClip(_ webClip: WebClip) {
        var webClips = loadWebClips()
        if let index = webClips.firstIndex(where: { $0.id == webClip.id }) {
            webClips[index] = webClip
            saveWebClips(webClips)
        }
    }
    
    private func encodeWebViewItem(_ item: WebClip) -> [String: Any] {
        var dict = [String: Any]()
        dict["id"] = item.id.uuidString
        dict["url"] = item.url.absoluteString
        dict["pageTitle"] = item.pageTitle ?? ""
        dict["screenshotPath"] = item.screenshotPath ?? ""
        dict["scrollY"] = item.scrollY ?? 0
        
        // Encode screenshot as Base64 string
        if let screenshot = item.screenshot, let imageData = screenshot.pngData() {
            dict["screenshot"] = imageData.base64EncodedString()
        }
        
        // Encode CGRect and CGSize
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
        
        // Encode CapturedElement and HTMLElement using JSON serialization
        if let capturedElements = item.capturedElements {
            dict["capturedElements"] = try? JSONEncoder().encode(capturedElements).base64EncodedString()
        }
        
        if let htmlElements = item.htmlElements {
            dict["htmlElements"] = try? JSONEncoder().encode(htmlElements).base64EncodedString()
        }
        
        // Encode Snapshots
        dict["snapshots"] = try? JSONEncoder().encode(item.snapshots).base64EncodedString()
        
        return dict
    }
    
    private func decodeWebViewItem(dict: [String: Any]) -> WebClip? {
        guard let idString = dict["id"] as? String,
              let id = UUID(uuidString: idString),
              let urlString = dict["url"] as? String,
              let url = URL(string: urlString) else {
            return nil
        }
        
        let pageTitle = dict["pageTitle"] as? String
        let screenshotPath = dict["screenshotPath"] as? String
        let scrollY = dict["scrollY"] as? Double
        let clipRect = decodeRect(dict: dict["clipRect"] as? [String: Any])
        let originalSize = decodeSize(dict: dict["originalSize"] as? [String: Any])
        
        var screenshot: UIImage?
        if let screenshotString = dict["screenshot"] as? String, let imageData = Data(base64Encoded: screenshotString) {
            screenshot = UIImage(data: imageData)
        }
        
        var capturedElements: [CapturedElement]?
        if let elementsString = dict["capturedElements"] as? String, let elementsData = Data(base64Encoded: elementsString) {
            capturedElements = try? JSONDecoder().decode([CapturedElement].self, from: elementsData)
        }
        
        var htmlElements: [HTMLElement]?
        if let elementsString = dict["htmlElements"] as? String, let elementsData = Data(base64Encoded: elementsString) {
            htmlElements = try? JSONDecoder().decode([HTMLElement].self, from: elementsData)
        }
        
        var snapshots: [SnapshotTimelineModel]?
        if let snapshotsString = dict["snapshots"] as? String, let snapshotsData = Data(base64Encoded: snapshotsString) {
            snapshots = try? JSONDecoder().decode([SnapshotTimelineModel].self, from: snapshotsData)
        }
        
        return WebClip(id: id, url: url, clipRect: clipRect, originalSize: originalSize, screenshotPath: screenshotPath, screenshot: screenshot, scrollY: scrollY, pageTitle: pageTitle, capturedElements: capturedElements, htmlElements: htmlElements, snapshots: snapshots)
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
