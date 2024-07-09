import Foundation
import SwiftUI

class WebClipEditorViewModel: ObservableObject {
    @Published var showingURLModal = false
    @Published var urls: [WebClip] = []
    @Published var urlString = ""
    @Published var validURL:URL?
    @Published var isEditing = false
    @Published var selectedURLIndex: Int? = nil
    @Published var isURLValid = true
    @Published var originalSize: CGSize?
    
    private var userDefaultsViewModel = WebClipUserDefaultsViewModel.shared

    
    // Add a computed property to access a specific WebClip by ID
    func webClip(withId id: UUID) -> WebClip? {
        return urls.first(where: { $0.id == id })
    }
    
    func imageForWebClip(withId id: UUID) -> UIImage? {
        guard let webClip = webClip(withId: id) else { return nil }
        return loadImage(from: webClip.screenshotPath)
    }
    
    init() {
        loadURLs()
    }
    
    func saveOriginalSize(newOriginalSize: CGSize){
        originalSize = newOriginalSize
    }
    
    func toggleURLModal() {
        showingURLModal.toggle()
    }
    
    func loadURLs() {
        urls = userDefaultsViewModel.loadWebViewItems()
    }
    
    func saveURLs() {
        userDefaultsViewModel.saveWebViewItems(urls)
    }
    
    func validateURL() {
        let (isValid, url) = URLUtilities.validateURL(from: urlString)
        isURLValid = isValid
        validURL = url
    }
    
    
    func saveURL(with screenshot: UIImage?, currentClipRect: CGRect?, pageTitle: String?) {
        guard isURLValid, let validURL = URL(string: urlString) else { return }
        
        let screenshotPath = screenshot.flatMap(ScreenshotUtils.saveScreenshotToLocalDirectory)
        let newWebClip = WebClip(
            id: isEditing && selectedURLIndex != nil ? urls[selectedURLIndex!].id : UUID(),
            url: validURL,
            clipRect: currentClipRect,
            originalSize: originalSize,
            screenshotPath: screenshotPath ?? "",
            pageTitle: pageTitle
        )
        
        if isEditing, let index = selectedURLIndex {
            urls[index] = newWebClip
        } else {
            urls.append(newWebClip)
        }
        saveURLs()
        resetModalState()
    }
    
    func updateWebClip(withId id: UUID, newURL: URL, newClipRect: CGRect?, newScreenshotPath: String?, pageTitle: String?) {
        guard let index = urls.firstIndex(where: { $0.id == id }) else { return }
        var webClip = urls[index]        
        webClip.url = newURL
        webClip.clipRect = newClipRect
        webClip.screenshotPath = newScreenshotPath
        webClip.pageTitle = pageTitle
        urls[index] = webClip
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
        if let index = urls.firstIndex(where: { $0.id == item.id }) {
            selectedURLIndex = index
            urlString = urls[index].url.absoluteString
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
