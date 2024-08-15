import SwiftUI

struct WebClipEditorView: View {
    @Environment(WebClipManagerViewModel.self) private var webClipManager
    @StateObject var captureMenuViewModel = WebClipSelectorViewModel()
    var webClipId: UUID
    
    var body: some View {
        WebClipCreatorView()
            .onAppear {
                webClipManager.openEditForItem(webClipId)
            }.onDisappear {
                webClipManager.reset()
                print("editor reset")
            }
    }
}

struct WebClipEditorView_Previews: PreviewProvider {
    static var previews: some View {
        let captureModel = WebClipSelectorViewModel()
        let webClipManager = WebClipManagerViewModel()
        // Provide a sample WebClip instance
        let sampleWebClip = WebClip(
            id: UUID(),
            url: URL(string: "https://news.ycombinator.com/")!,
            clipRect: CGRect(x: 0, y: 0, width: 300, height: 200),
            originalSize: CGSize(width: 800, height: 600),
            scrollY: 100,
            pageTitle: "Hacker News",
            capturedElements: [],
            htmlElements: [],
            snapshots: []
        )
        WebClipEditorView(captureMenuViewModel: captureModel, webClipId: sampleWebClip.id)
    }
}
