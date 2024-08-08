import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @ObservedObject private var webClips = WebClipManagerViewModel.shared
    
    var body: some View {
        NavigationStack{
            VStack {
                BlackMenuBarView(viewModel: webClips)
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))]) {
                        Text("Glanceables")
                            .font(.system(.largeTitle, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundColor(Color.black)
                    }
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))]) {
                        if webClips.webClips.isEmpty {
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
        ForEach(webClips.webClips, id: \.id) { item in
            WebGridSingleSnapshotView(item: item)
                .contextMenu {
                    NavigationLink(destination: WebClipEditorView(webClip: item)) {
                        Text("Edit")
                    }
                    Button("Delete") {
                        webClips.deleteItem(item: item)
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
