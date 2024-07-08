import Foundation
import SwiftUI

class WebClipEditorViewModel: ObservableObject {
    @Published var showingURLModal = false
    @Published var urls: [WebClip] = []
    @Published var urlString = ""
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
        isURLValid = URL(string: urlString) != nil
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
