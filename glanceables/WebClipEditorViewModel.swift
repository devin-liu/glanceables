import Foundation
import SwiftUI

class WebClipEditorViewModel: ObservableObject {
    static let shared = WebClipEditorViewModel()  // Singleton instance
    @Published var showingURLModal = false
    @Published var webClips: [WebClip] = []
    @Published var urlString = ""
    @Published var validURL:URL?
    @Published var isEditing = false
    @Published var selectedURLIndex: Int? = nil
    @Published var currentClipRect: CGRect?
    @Published var isURLValid = true
    @Published var showValidationError = false
    @Published var originalSize: CGSize?
    @Published var pageTitle: String?
    @Published var screenShot: UIImage?
    @Published var screenshotPath: String?
    
    private var userDefaultsViewModel = WebClipUserDefaultsViewModel.shared
    
    // Add a computed property to access a specific WebClip by ID
    func webClip(withId id: UUID) -> WebClip? {
        return webClips.first(where: { $0.id == id })
    }
    
    func imageForWebClip(withId id: UUID) -> UIImage? {
        guard let webClip = webClip(withId: id) else { return nil }
        return loadImage(from: webClip.screenshotPath)
    }
    
    init() {
        loadURLs()
    }
    
    func saveScreenShot(_ newScreenShot: UIImage){
        screenShot = newScreenShot
    }
    
    func saveOriginalSize(newOriginalSize: CGSize){
        originalSize = newOriginalSize
    }
    
    func toggleURLModal() {
        showingURLModal.toggle()
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
        validURL = url
    }
    
    
    //    func saveURL(screenshot: UIImage?, capturedElements: [CapturedElement]?, id: UUID? = nil) {
    //        guard isURLValid, validURL != nil else { return }
    //        
    //        let newId = id ?? UUID()
    //        
    //        // Save the screenshot to the local directory and get the path
    //        screenshotPath = screenshot.flatMap(ScreenshotUtils.saveScreenshotToLocalDirectory)
    //        
    //        // Create a new WebClip object
    //        let newWebClip = WebClip(
    //            id: newId,
    //            url: validURL!,
    //            clipRect: currentClipRect,
    //            originalSize: originalSize,
    //            screenshotPath: screenshotPath ?? "",
    //            pageTitle: pageTitle,
    //            capturedElements: capturedElements
    //        )
    //        
    //        // Update the webClips array
    //        if isEditing, let index = selectedURLIndex {
    //            webClips[index] = newWebClip
    //        } else {
    //            webClips.append(newWebClip)
    //        }
    //        
    //        // Save the URLs and reset the modal state
    //        saveURLs()
    //        resetModalState()
    //    }
    
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
        resetModalState()
    }
    
    //    func updateWebClip(withId id: UUID, urlString: String, screenshot: UIImage?, newClipRect: CGRect?, newPageTitle: String?, capturedElements: [CapturedElement]?) -> Bool {
    //        let (isValid, url) = URLUtilities.validateURL(from: urlString)
    //        guard isValid, let validURL = url, let index = webClips.firstIndex(where: { $0.id == id }) else {
    //            return false
    //        }
    //
    //        var webClip = webClips[index]
    //        webClip.url = validURL
    //        webClip.clipRect = newClipRect ?? webClip.clipRect
    //        webClip.pageTitle = newPageTitle ?? webClip.pageTitle
    //        webClip.capturedElements = capturedElements ?? webClip.capturedElements
    //        webClip.screenshotPath = screenshot.flatMap(ScreenshotUtils.saveScreenshotToLocalDirectory) ?? webClip.screenshotPath
    //
    //        webClips[index] = webClip
    //        saveURLs()
    //
    //        return true
    //    }
    func updateWebClip(withId id: UUID, newURL: URL? = nil, newClipRect: CGRect? = nil, newScreenshotPath: String? = nil, newPageTitle: String? = nil, newCapturedElements: [CapturedElement]? = nil) {
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
        
        webClips[index] = webClip
        saveURLs()
    }
    
    
    
    func resetModalState() {
        showingURLModal = false
        urlString = ""
        isEditing = false
        selectedURLIndex = nil
        isURLValid = true
    }
    
    func openEditForItem(item: WebClip) {
        if let index = webClips.firstIndex(where: { $0.id == item.id }) {
            selectedURLIndex = index
            urlString = webClips[index].url.absoluteURL.absoluteString
            isEditing = true
            showingURLModal = true
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
