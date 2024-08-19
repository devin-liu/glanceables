import SwiftUI
import UniformTypeIdentifiers

struct WebClipGridView: View {
    @Environment(WebClipManagerViewModel.self) private var webClipManager
    
    var body: some View {
        WebClipGridItems(webClips: webClipManager.getClips())
            .animation(.easeInOut, value: webClipManager.getClips())
    }
}

struct WebClipGridItems: View {
    @Environment(WebClipManagerViewModel.self) private var webClipManager
    var webClips: [WebClip]
    
    let columns = [GridItem(.adaptive(minimum: 300))]
    
    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(webClips, id: \.self) { item in
                VStack {
                    GridScreenshotView(webClipId: item.id)
                        .padding(10)
                    
                    WebGridSingleSnapshotView(item: item)
                    
                    
                } .contextMenu {
                    NavigationLink(destination: WebClipEditorView(webClipId: item.id)) {
                        Text("Edit")
                    }
                    Button("Delete") {
                        webClipManager.deleteItemById(item.id)
                    }
                }
            }
        }
        
        WebClipRefresherGrid()
    }
}
