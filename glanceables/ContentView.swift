import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var webClipEditorViewModel = WebClipEditorViewModel()

//    @State private var showingURLModal = false
    @State private var urls: [WebClip] = []
    @State private var draggedItem: WebClip?
    @State private var urlString = ""
    @State private var isEditing = false
    @State private var selectedURLIndex: Int? = nil
    @State private var isURLValid = true
    
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
                    if urls.isEmpty {
                        emptyStateView
                    } else {
                        urlGrid
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .onAppear {
                loadURLs()
            }
            .onChange(of: urls, initial: false) {
                saveURLs()
            }
            .fullScreenCover(isPresented:$webClipEditorViewModel.showingURLModal) {
                WebPreviewCaptureMenuView(showingURLModal: $webClipEditorViewModel.showingURLModal, urlString: $urlString, isURLValid: $isURLValid, urls: $urls, selectedURLIndex: $selectedURLIndex, isEditing: $isEditing)
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
        ForEach($urls) { $item in
            WebGridSingleSnapshotView(item: $item)
                .onDrag {
                    self.draggedItem = item
                    return NSItemProvider(object: item.url.absoluteString as NSString)
                }
                .onDrop(of: [UTType.text], delegate: DropViewDelegate(item: item, viewModel: $urls, draggedItem: $draggedItem))
                .contextMenu {
                    Button(action: {
                        if let index = urls.firstIndex(where: { $0.id == item.id }) {
                            selectedURLIndex = index
                            urlString = urls[index].url.absoluteString
                            isEditing = true
                            webClipEditorViewModel.toggleURLModal()
                        }
                    }) {
                        Label("Edit", systemImage: "pencil")
                    }
                    Button(action: {
                        UserDefaultsManager.shared.deleteWebViewItem(item)
                        loadURLs()
                    }) {
                        Label("Delete", systemImage: "trash")
                    }
                }
        }
    }
    
    private func saveURLs() {
        UserDefaultsManager.shared.saveWebViewItems(urls)
    }
    
    private func loadURLs() {
        urls = UserDefaultsManager.shared.loadWebViewItems()
    }
    
    private func validateURL() {
        isURLValid = URL(string: urlString) != nil
    }
    
    private func resetModalState() {
//        showingURLModal = false
        urlString = ""
        isEditing = false
        selectedURLIndex = nil
        isURLValid = true
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
