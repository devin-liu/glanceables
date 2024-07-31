import Foundation
import SwiftUI

class WebClipEditorViewModel: ObservableObject {
    static let shared = WebClipEditorViewModel()  // Singleton instance
    @Published var webClips: [WebClip] = []
    @Published var urlString = ""
    @Published var validURLs: [URL] = []  // Now storing an array of URLs
    @Published var isEditing = false
    @Published var selectedValidURLIndex: Int? = nil {
        didSet {
            if let index = selectedValidURLIndex, validURLs.indices.contains(index) {
                urlString = validURLs[index].absoluteString
            } else {
                urlString = ""  // Clear urlString if there's no valid URL selected
            }
        }
    }
    @Published var selectedWebClipIndex: Int? = nil
    @Published var currentClipRect: CGRect?
    @Published var isURLValid = true
    @Published var showValidationError = false
    @Published var originalSize: CGSize?
    @Published var pageTitle: String?
    @Published var screenShot: UIImage?
    @Published var screenshotPath: String?
    
    private var userDefaultsViewModel = WebClipUserDefaultsViewModel.shared
    
    var validURL: URL? {
        guard let index = selectedValidURLIndex, validURLs.indices.contains(index) else {
            return nil
        }
        return validURLs[index]
    }
    
    func clearTextField() {
        urlString = ""
    }
    
    // Add a computed property to access a specific WebClip by ID
    func webClip(withId id: UUID) -> WebClip? {
        return webClips.first(where: { $0.id == id })
    }
    
    func selectedWebClip() -> WebClip? {
        guard let index = selectedWebClipIndex, webClips.indices.contains(index) else {
            return nil
        }
        return webClips[index]
    }
    
    
    func imageForWebClip(withId id: UUID) -> UIImage? {
        guard let webClip = webClip(withId: id) else { return nil }
        return loadImage(from: webClip.screenshotPath)
    }
    
    
    init() {
        loadURLs()
    }
    
    func saveScreenShot(_ newScreenShot: UIImage) {
        screenShot = newScreenShot
    }
    
    func saveOriginalSize(newOriginalSize: CGSize) {
        originalSize = newOriginalSize
    }
    
    func loadURLs() {
        webClips = userDefaultsViewModel.loadWebViewItems()
    }
    
    func saveURLs() {
        userDefaultsViewModel.saveWebViewItems(webClips)
    }
    
    func validateURL() {
        let (isValid, url) = URLUtilities.validateURL(from: urlString)
        isURLValid = isValid
        if let url = url {
            if validURLs.isEmpty {
                validURLs.append(url)
                selectedValidURLIndex = 0 // Initialize the index with the first URL
            } else {
                updateOrAddValidURL(url)
            }
        }
    }
    
    func updateOrAddValidURL(_ newURL: URL) {
        if let selectedIndex = selectedValidURLIndex,
           let currentURL = validURL,
           let newDomain = URLUtilities.extractDomain(from: newURL.absoluteString),
           let currentDomain = URLUtilities.extractDomain(from: currentURL.absoluteString),
           newDomain == currentDomain {
            validURLs[selectedIndex] = newURL // Replace the URL at the current index if domains match
        } else {
            // There is no selected index or domains are not provided; skip domain checking
            print("No selected index or domain provided; adding URL")
            validURLs.append(newURL)
            selectedValidURLIndex = validURLs.count - 1 // Update the index to the new URL if not set
        }
    }
    
    func addWebClip(screenshot: UIImage?, capturedElements: [CapturedElement]?) {
        guard isURLValid, validURL != nil else { return }
        
        let newWebClip = WebClip(
            id: UUID(),
            url: validURL!,
            clipRect: currentClipRect,
            originalSize: originalSize,
            screenshotPath: screenshot.flatMap(ScreenshotUtils.saveScreenshotToLocalDirectory) ?? "",
            pageTitle: pageTitle,
            capturedElements: capturedElements
        )
        
        webClips.append(newWebClip)
        saveURLs()
    }
    
    func updateWebClip(withId id: UUID, newURL: URL? = nil, newClipRect: CGRect? = nil, newScreenshotPath: String? = nil, newPageTitle: String? = nil, newCapturedElements: [CapturedElement]? = nil, newLlamaResult: LlamaResult? = nil) {
        guard let index = webClips.firstIndex(where: { $0.id == id }) else {
            return
        }
        
        var webClip = webClips[index]
        
        // Update only if new values are provided
        if let newURL = newURL {
            webClip.url = newURL
        }
        if let newClipRect = newClipRect {
            webClip.clipRect = newClipRect
        }
        if let newScreenshotPath = newScreenshotPath {
            webClip.screenshotPath = newScreenshotPath
        }
        if let newPageTitle = newPageTitle {
            webClip.pageTitle = newPageTitle
        }
        if let newCapturedElements = newCapturedElements {
            webClip.capturedElements = newCapturedElements
        }
        if let newLlamaResult = newLlamaResult {
            webClip.llamaResult = newLlamaResult
        }
        
        webClips[index] = webClip
        saveURLs()
    }
    
    func resetModalState() {
        urlString = ""
        isEditing = false
        selectedWebClipIndex = nil
        isURLValid = true
    }
    
    func openEditForItem(item: WebClip) {
        if let index = webClips.firstIndex(where: { $0.id == item.id }) {
            selectedWebClipIndex = index
            urlString = webClips[index].url.absoluteURL.absoluteString
            isEditing = true
        }
    }
    
    func deleteItem(item: WebClip) {
        userDefaultsViewModel.deleteWebViewItem(item)
        loadURLs()
    }
    
    private func updateScreenshotPath(_ id: UUID, _ newPath: String) {
        if let webClip = webClip(withId: id) {
            var updatedItem = webClip
            updatedItem.screenshotPath = newPath
        }
    }
    
    func loadImage(from path: String?) -> UIImage? {
        guard let path = path else { return nil }
        let url = URL(fileURLWithPath: path)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }
}
