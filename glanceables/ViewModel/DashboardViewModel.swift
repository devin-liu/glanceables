import SwiftUI
import Combine

class DashboardViewModel: ObservableObject {
    static let shared = DashboardViewModel()  // Singleton instance
    @Published var showingURLModal: Bool = false
    @Published var draggedItem: WebClip?
    @Published var webClips: [WebClip] = []
    
    private let webClipEditorViewModel = WebClipEditorViewModel.shared
    
    init() {
        loadURLs()
    }
    
    func loadURLs() {
        webClips = webClipEditorViewModel.webClips
    }
    
    func openEditForItem(item: WebClip) {
        webClipEditorViewModel.openEditForItem(item: item)
        showingURLModal = true
    }
    
    func deleteItem(item: WebClip) {
        webClipEditorViewModel.deleteItem(item: item)
        loadURLs() // Refresh the local list after deletion
    }
    
    func moveItem(fromOffsets: IndexSet, toOffset: Int) {
        webClips.move(fromOffsets: fromOffsets, toOffset: toOffset)
        // Update the main view model
        webClipEditorViewModel.webClips = webClips
    }
    
    func resetModalView() {
        webClipEditorViewModel.resetModalState()
        showingURLModal = false
    }
}
