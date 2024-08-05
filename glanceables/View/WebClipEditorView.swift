import SwiftUI

struct WebClipEditorView: View {
    @StateObject private var captureMenuViewModel = DraggableWebCaptureViewModel()
    var webClip: WebClip  // This holds the web clip data to edit
    
    var body: some View {
        WebClipCreatorView()
        .onAppear {
            WebClipEditorViewModel.shared.openEditForItem(webClip)
            WebClipEditorViewModel.shared.validateURL()
        }
    }
}

struct WebClipEditorView_Previews: PreviewProvider {
    static var previews: some View {
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
            llamaResult: nil,
            snapshots: []
        )
        WebClipEditorView(webClip: sampleWebClip)
    }
}
