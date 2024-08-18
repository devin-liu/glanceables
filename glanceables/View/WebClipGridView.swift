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
                        .onDisappear {
                            print("ScreenshotView onDisappear")
                        }
                    
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
        
        LazyVGrid(columns: columns) {
            ForEach(webClips, id: \.self) { item in
                WebViewSnapshotRefresher(webClipId: item.id)
                    .frame(width: item.originalSize?.width, height: 600)
                    .edgesIgnoringSafeArea(.all)
                    .opacity(0)  // Make the ScrollView invisible
                    .frame(width: 0, height: 0)  // Make the ScrollView occupy no space
                    .onDisappear {
                        print("WebViewSnapshotRefresher onDisappear")
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
