import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var showingURLModal = false
    @State private var urls: [WebViewItem] = []
    @State private var draggedItem: WebViewItem?
    @State private var urlString = ""
    @State private var isEditing = false
    @State private var selectedURLIndex: Int? = nil
    @State private var isURLValid = true

    var body: some View {
        VStack {
            BlackMenuBarView(isShowingModal: $showingURLModal)
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
            .onChange(of: urls) {
                saveURLs()
            }
            .fullScreenCover(isPresented: $showingURLModal) {
                WebPreviewCaptureView(showingURLModal: $showingURLModal, urlString: $urlString, isURLValid: $isURLValid, urls: $urls, selectedURLIndex: $selectedURLIndex, isEditing: $isEditing)
            }
        }
    }

    var emptyStateView: some View {
        VStack {
            Spacer()
            CreateButtonView(isShowingModal: $showingURLModal)
                .padding()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    var urlGrid: some View {
        ForEach(urls) { item in
            WebGridSingleSnapshotView(item: item)
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
                            showingURLModal = true
                        }
                    }) {
                        Label("Edit", systemImage: "pencil")
                    }
                    Button(action: {
                        if let index = urls.firstIndex(where: { $0.id == item.id }) {
                            urls.remove(at: index)
                            saveURLs()
                        }
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
        showingURLModal = false
        urlString = ""
        isEditing = false
        selectedURLIndex = nil
        isURLValid = true
    }
}

struct DropViewDelegate: DropDelegate {
    let item: WebViewItem
    @Binding var viewModel: [WebViewItem]
    @Binding var draggedItem: WebViewItem?

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
