import SwiftUI
import WebKit

struct ContentView: View {
    @State private var showingURLModal = false
    @State private var urls: [String] = []
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
        .onChange(of: urls) { _ in
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
        ForEach(urls, id: \.self) { urlString in
            if let url = URL(string: urlString) {
                WebBrowserView(url: url)
                    .contextMenu {
                        Button(action: {
                            if let index = urls.firstIndex(of: urlString) {
                                selectedURLIndex = index
                                self.urlString = urlString
                                isEditing = true
                                showingURLModal = true
                            }
                        }) {
                            Label("Edit", systemImage: "pencil")
                        }
                        Button(action: {
                            deleteURL(urlString)
                        }) {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
        .onDelete(perform: deleteItems)
    }

    private func deleteURL(_ urlString: String) {
        urls = urls.filter { $0 != urlString }
        saveURLs()  // Save the modified list to UserDefaults
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
    }
}
