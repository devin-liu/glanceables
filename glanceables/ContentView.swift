import SwiftUI
import WebKit

struct ContentView: View {
    @State private var showingAddURLModal = false // State to manage modal visibility
    @State private var urls: [String] = []
    @State private var newURLString = "" // State to capture the new URL input

    var body: some View {
        BlackMenuBarView(isShowingModal: $showingAddURLModal)
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
        .sheet(isPresented: $showingAddURLModal) {
            addURLModal
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
            CreateButtonView(isShowingModal: $showingAddURLModal)
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

    var addURLModal: some View {
        NavigationView {
            Form {
                Section(header: Text("Add a new URL")) {
                    TextField("Enter URL here", text: $newURLString)
                }
                Section {
                    Button("Save") {
                        if !newURLString.isEmpty {
                            urls.append(newURLString)
                            newURLString = "" // Reset the text field
                            showingAddURLModal = false // Dismiss the modal
                        }
                    }
                }
            }
            .navigationBarTitle("New URL", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                showingAddURLModal = false
                newURLString = "" // Reset the text field
            })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
