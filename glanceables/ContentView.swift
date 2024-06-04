import SwiftUI
import WebKit

struct ContentView: View {
    @State private var showingURLModal = false // State to manage modal visibility
    @State private var urls: [String] = []
    @State private var urlString = "" // State to capture the URL input
    @State private var isEditing = false // State to determine if editing or adding a URL
    @State private var selectedURLIndex: Int? = nil // State to capture the index of the URL being edited

    var body: some View {
        BlackMenuBarView(isShowingModal: $showingURLModal)
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))]) {
                Text("Glanceables")
                    .font(.system(.largeTitle, design: .rounded)) // Use dynamic type with style
                    .fontWeight(.medium) // Medium font weight
                    .foregroundColor(Color.black) // Text color set to gray
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
            urlModal
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

    // Function to delete a URL from the array
    private func deleteURL(_ urlString: String) {
        urls = urls.filter { $0 != urlString }
        saveURLs()  // Save the modified list to UserDefaults
    }

    // Function to handle swipe to delete
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

    var urlModal: some View {
        NavigationView {
            Form {
                Section(header: Text(isEditing ? "Edit URL" : "Add a new URL")) {
                    TextField("Enter URL here", text: $urlString)
                }
                Section {
                    Button("Save") {
                        if !urlString.isEmpty {
                            if isEditing, let index = selectedURLIndex {
                                urls[index] = urlString
                            } else {
                                urls.append(urlString)
                            }
                            resetModalState()
                        }
                    }
                }
            }
            .navigationBarTitle(isEditing ? "Edit URL" : "New URL", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                resetModalState()
            })
        }
    }

    private func resetModalState() {
        showingURLModal = false
        urlString = "" // Reset the text field
        isEditing = false
        selectedURLIndex = nil // Reset the selected index
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
