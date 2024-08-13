import SwiftUI
import UniformTypeIdentifiers

struct WebClipGridView: View {
    var webClipManager: WebClipManagerViewModel
    
    var body: some View {
        Text("WebClips available: \(webClipManager.webClips.count)")
        WebClipGridItems(webClips: webClipManager.webClips, webClipManager: webClipManager)
        .animation(.easeInOut, value: webClipManager.webClips)
    }
}

struct WebClipGridItems: View {
    var webClips: [WebClip]
    var webClipManager: WebClipManagerViewModel
    
    let columns = [GridItem(.adaptive(minimum: 300))]
    
    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(webClips, id: \.self.id) { item in
                WebGridSingleSnapshotView(item: item, webClipManager: webClipManager)
                    .contextMenu {
                        NavigationLink(destination: WebClipEditorView(webClipManager: webClipManager, webClip: item)) {
                            Text("Edit")
                        }
                        Button("Delete") {
                            webClipManager.deleteItemById(item.id)
                        }
                    }
            }
            .onDelete(perform: { indexSet in
                indexSet.forEach { index in
                    let id = webClips[index].id
                    webClipManager.deleteItemById(id)
                }
            })
        }
    }
}

//struct WebClipGrid_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
