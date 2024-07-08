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
    
    init() {
        loadURLs()
    }
    
    func toggleURLModal() {
        showingURLModal.toggle()
    }
    
    func loadURLs() {
        urls = UserDefaultsManager.shared.loadWebViewItems()
    }
    
    func saveURLs() {
        UserDefaultsManager.shared.saveWebViewItems(urls)
    }
    
    func validateURL() {
        
        let (isValid, url) = URLUtilities.validateURL(from: urlString)
        isURLValid = isValid
        validURL = url
    }
    
    func saveURL(with screenshot: UIImage?, currentClipRect: CGRect?) {
        guard isURLValid, let validURL = URL(string: urlString) else { return }
        
        // Save the screenshot and check if the returned path is not nil
        guard let screenshotPath = screenshot.flatMap(ScreenshotUtils.saveScreenshotToLocalDirectory) else {
            // Handle the case where the screenshot could not be saved. Decide if you should return or handle differently
            return
        }
        
        let newWebClip = WebClip(
            id: UUID(),
            url: validURL,
            clipRect: currentClipRect,
            screenshotPath: screenshotPath
        )
        
        if isEditing, let index = selectedURLIndex {
            urls[index] = newWebClip
        } else {
            urls.append(newWebClip)
        }
        saveURLs()
        resetModalState()
    }
    
    
    func resetModalState() {
        showingURLModal = false
        urlString = ""
        isEditing = false
        selectedURLIndex = nil
        isURLValid = true
    }
    
    func handleEdit(item: WebClip) {
        if let index = urls.firstIndex(where: { $0.id == item.id }) {
            selectedURLIndex = index
            urlString = urls[index].url.absoluteString
            isEditing = true
            showingURLModal = true
        }
    }        
    
    func deleteItem(item: WebClip) {
        UserDefaultsManager.shared.deleteWebViewItem(item)
        loadURLs()
    }
}
