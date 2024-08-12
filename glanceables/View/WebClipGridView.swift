import SwiftUI
import UniformTypeIdentifiers

struct WebClipGridView: View {
    var webClipManager: WebClipManagerViewModel
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))]) {
            ForEach(webClipManager.webClips, id: \.id) { item in
                autoreleasepool {
                    WebGridSingleSnapshotView(item: item, webClipManager: webClipManager)
                        .contextMenu {
                            NavigationLink(destination: WebClipEditorView(webClip: item)) {
                                Text("Edit")
                            }
                            Button("Delete") {
                                webClipManager.deleteItem(item: item)
                            }
                        }
                }
            }
        }
    }
}

//struct WebClipGrid_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
