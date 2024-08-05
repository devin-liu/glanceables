import SwiftUI
import Combine

class DashboardViewModel: ObservableObject {
    static let shared = DashboardViewModel()  // Singleton instance
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
        webClipEditorViewModel.openEditForItem(item)
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
        loadURLs()
    }
}
