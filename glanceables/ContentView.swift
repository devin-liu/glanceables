import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var webClipEditorViewModel = WebClipEditorViewModel.shared
    @State private var draggedItem: WebClip?
    
    var body: some View {
        VStack {
            BlackMenuBarView(isShowingModal: $webClipEditorViewModel.showingURLModal)
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))]) {
                    Text("Glanceables")
                        .font(.system(.largeTitle, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundColor(Color.black)
                }
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))]) {
                    if webClipEditorViewModel.urls.isEmpty {
                        emptyStateView
                    } else {
                        urlGrid
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .onAppear {
                webClipEditorViewModel.loadURLs()
            }
            .fullScreenCover(isPresented: $webClipEditorViewModel.showingURLModal) {
                WebPreviewCaptureMenuView(viewModel: webClipEditorViewModel)
            }
        }
    }
    
    var emptyStateView: some View {
        VStack {
            Spacer()
            CreateButtonView(isShowingModal: $webClipEditorViewModel.showingURLModal)
                .padding()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var urlGrid: some View {
        ForEach(webClipEditorViewModel.urls) { item in
            WebGridSingleSnapshotView(id: item.id)
                .onDrag {
                    self.draggedItem = item  // Ensure draggedItem is a @State or similar to hold the state
                    return NSItemProvider(object: item.url.absoluteString as NSString)
                }
                .onDrop(of: [UTType.text], delegate: DropViewDelegate(item: item, viewModel: $webClipEditorViewModel.urls, draggedItem: $draggedItem))
            
                .contextMenu {
                    Button("Edit") {
                        webClipEditorViewModel.openEditForItem(item: item)
                    }
                    Button("Delete") {
                        webClipEditorViewModel.deleteItem(item: item)
                    }
                }
        }
    }
}

struct DropViewDelegate: DropDelegate {
    let item: WebClip
    @Binding var viewModel: [WebClip]
    @Binding var draggedItem: WebClip?
    
    func dropEntered(info: DropInfo) {
        guard let draggedItem = draggedItem, draggedItem.id != item.id else { return }
        
        if let fromIndex = viewModel.firstIndex(where: { $0.id == draggedItem.id }),
           let toIndex = viewModel.firstIndex(where: { $0.id == item.id }) {
            withAnimation {
                viewModel.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
            }
        }
    }
    
    func performDrop(info: DropInfo) -> Bool {
        self.draggedItem = nil
        return true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
