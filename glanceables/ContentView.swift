import SwiftUI
import WebKit

// WebView wrapper for displaying web content with zoom and scroll capabilities
struct WebView: UIViewRepresentable {
    @Binding var url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.isScrollEnabled = true
        webView.scrollView.minimumZoomScale = 1.0
        webView.scrollView.maximumZoomScale = 3.0
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    func makeCoordinator() -> WebViewCoordinator {
        return WebViewCoordinator()
    }
}

class WebViewCoordinator: NSObject, WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("WebView load failed: \(error.localizedDescription)")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("WebView provisional load failed: \(error.localizedDescription)")
    }
}

struct ContentView: View {
    let columnLayout = Array(repeating: GridItem(), count: 3)

    @State private var showingAddURLModal = false // State to manage modal visibility
    @State private var urls: [String] = []
    @State private var newURLString = "" // State to capture the new URL input


    var body: some View {
        ScrollView {
            LazyVGrid(columns: columnLayout) {
                Text("Glanceables")
                    .font(.system(size: 60)) // Smaller font size for the text
                    .fontWeight(.medium) // Medium font weight
                    .foregroundColor(Color.black) // Text color set to gray
                    
            }
            LazyVGrid(columns: columnLayout) {
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
                        .frame(height: 300)
                }
            }
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


#Preview {
    ContentView()
}

