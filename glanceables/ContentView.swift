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

    @State private var urlString = "https://maps.app.goo.gl/DaxShLmLsBvqTVwz7"
    @State private var url = URL(string: "https://maps.app.goo.gl/DaxShLmLsBvqTVwz7")!
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columnLayout) {
                WebBrowserView(url: URL(string: "https://maps.app.goo.gl/DaxShLmLsBvqTVwz7") ?? URL(string: "https://fallback-url.com")!)
                    .frame(height: 300)
                
                WebBrowserView(url: URL(string: "https://www.caltrain.com/") ?? URL(string: "https://fallback-url.com")!)
                    .frame(height: 300)
                
            }
        }
        .padding()
                    .background(Color.black.opacity(0.8))
    }
}
