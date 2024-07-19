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
    
    
    func saveURL(screenshot: UIImage?, capturedElements: [CapturedElement]?) {
        guard isURLValid, let validURL = URL(string: urlString) else { return }
        
        print("saveURL ", capturedElements)
        
        screenshotPath = screenshot.flatMap(ScreenshotUtils.saveScreenshotToLocalDirectory)
        let newWebClip = WebClip(
            id: isEditing && selectedURLIndex != nil ? webClips[selectedURLIndex!].id : UUID(),
            url: validURL,
            clipRect: currentClipRect,
            originalSize: originalSize,
            screenshotPath: screenshotPath ?? "",
            pageTitle: pageTitle,
            capturedElements: capturedElements
        )
        
        if isEditing, let index = selectedURLIndex {
            webClips[index] = newWebClip
        } else {
            webClips.append(newWebClip)
        }
        saveURLs()
        resetModalState()
    }
    
    func updateWebClip(withId id: UUID, newURL: URL, newClipRect: CGRect?, newScreenshotPath: String?, newPageTitle: String?) {
        guard let index = webClips.firstIndex(where: { $0.id == id }) else { return }
        var webClip = webClips[index]
        webClip.url = newURL
        webClip.clipRect = newClipRect
        webClip.screenshotPath = newScreenshotPath
        webClip.pageTitle = newPageTitle
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
            urlString = webClips[index].url.absoluteString
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
