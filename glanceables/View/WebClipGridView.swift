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
            ForEach(webClips, id: \.self) { item in
                VStack {
                    GridScreenshotView(item: item, webClipManager: webClipManager)
                        .padding(10)
                        .onDisappear {
                            print("ScreenshotView onDisappear")
                        }
                    
                    WebGridSingleSnapshotView(item: item)
                       
                } .contextMenu {
                    NavigationLink(destination: WebClipEditorView(webClipManager: webClipManager, webClipId: item.id)) {
                        Text("Edit")
                    }
                    Button("Delete") {
                        webClipManager.deleteItemById(item.id)
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