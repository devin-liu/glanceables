import SwiftUI
import WebKit

struct ContentView: View {
    @EnvironmentObject var positionManager: ViewPositionManager
    @State private var showingURLModal = false
    @State private var urls: [String] = []  // This stores the URLs as strings
    @State private var urlString = ""
    @State private var isEditing = false
    @State private var selectedURLIndex: Int? = nil
    @State private var isURLValid = true

    var body: some View {
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
        .sheet(isPresented: $showingURLModal) {
            URLModalView(showingURLModal: $showingURLModal, urlString: $urlString, isURLValid: $isURLValid, urls: $urls, selectedURLIndex: $selectedURLIndex, isEditing: $isEditing)
        }
        .onAppear {
            loadURLs()
        }
        .onChange(of: urls) {
            saveURLs()
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
        ForEach(urls.indices, id: \.self) { index in
            if let url = URL(string: urls[index]) {
                let viewID = UUID(uuidString: urls[index].hashValue.description) ?? UUID()
                WebBrowserView(url: url, id: viewID)
                    .environmentObject(positionManager)
                    .contextMenu {
                        Button(action: {
                            selectedURLIndex = index
                            urlString = urls[index]
                            isEditing = true
                            showingURLModal = true
                        }) {
                            Label("Edit", systemImage: "pencil")
                        }
                        Button(action: {
                            deleteURL(at: index)
                        }) {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
        .onDelete(perform: deleteItems)
    }

    private func deleteURL(at index: Int) {
        urls.remove(at: index)
        saveURLs()
    }

    private func deleteItems(at offsets: IndexSet) {
        urls.remove(atOffsets: offsets)
        saveURLs()
    }

    private func loadURLs() {
        urls = UserDefaultsManager.shared.loadURLs()
    }

    private func saveURLs() {
        UserDefaultsManager.shared.saveURLs(urls)
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ViewPositionManager())
    }
}
