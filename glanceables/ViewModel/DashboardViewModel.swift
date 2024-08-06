import SwiftUI
import Combine

class DashboardViewModel: ObservableObject {
    static let shared = DashboardViewModel()  // Singleton instance
    @Published var draggedItem: WebClip?
    @Published var webClips: [WebClip] = []
    
    private var subscriptions = Set<AnyCancellable>()
    private let webClipManagerViewModel = WebClipManagerViewModel.shared
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        webClipManagerViewModel.webClipsPublisher
            .receive(on: RunLoop.main)  // Ensure UI updates are on the main thread
            .assign(to: \.webClips, on: self)
            .store(in: &subscriptions)
    }
    
    func openEditForItem(item: WebClip) {
        webClipManagerViewModel.openEditForItem(item)
    }
    
    func deleteItem(item: WebClip) {
        webClipManagerViewModel.deleteItem(item: item)
    }
    
    func moveItem(fromOffsets: IndexSet, toOffset: Int) {
        webClipManagerViewModel.moveItem(fromOffsets: fromOffsets, toOffset: toOffset)
    }
}
