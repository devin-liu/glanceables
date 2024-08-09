import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var webClipManager = WebClipManagerViewModel()
    
    var body: some View {
        NavigationStack{
            VStack {
                BlackMenuBarView(viewModel: webClipManager)
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))]) {
                        Text("Glanceables")
                            .font(.system(.largeTitle, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundColor(Color.black)
                    }
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))]) {
                        if webClipManager.webClips.isEmpty {
                            emptyStateView
                        } else {
                            urlGrid
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6).opacity(0.85))
            }
        }
    }
    
    var emptyStateView: some View {
        VStack {
            Spacer()
            CreateButtonView()
                .padding()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var urlGrid: some View {
        ForEach(webClipManager.webClips, id: \.id) { item in
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
