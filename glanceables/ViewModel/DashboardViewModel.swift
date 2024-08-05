import SwiftUI
import Combine

class DashboardViewModel: ObservableObject {
    static let shared = DashboardViewModel()  // Singleton instance
    @Published var draggedItem: WebClip?
    @Published var webClips: [WebClip] = []
    
    private let webClipEditorViewModel = WebClipManagerViewModel.shared
    private var cancellables: Set<AnyCancellable> = []  // Storage for Combine subscribers
    
    init() {
        setupSubscriptions()
        loadURLs()
    }
    
    func setupSubscriptions() {
        // Subscribe to changes in webClips from the editor VM
        webClipEditorViewModel.$webClips
            .sink { [weak self] updatedClips in
                self?.webClips = updatedClips
            }
            .store(in: &cancellables)
    }
    
    func loadURLs() {
        // Initial load from webClipEditorViewModel
        webClips = webClipEditorViewModel.webClips
    }
    
    func openEditForItem(item: WebClip) {
        webClipEditorViewModel.openEditForItem(item)
    }
    
    func deleteItem(item: WebClip) {
        webClipEditorViewModel.deleteItem(item: item)        
    }
    
    func moveItem(fromOffsets: IndexSet, toOffset: Int) {
        webClips.move(fromOffsets: fromOffsets, toOffset: toOffset)
        webClipEditorViewModel.webClips = webClips
    }        
}
