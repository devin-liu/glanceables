import SwiftUI
import WebKit

// WebView wrapper for displaying web content with zoom, scroll, and refresh capabilities
struct WebView: UIViewRepresentable {
    @Binding var url: URL
    @Binding var pageTitle: String
    var refreshAction: (() -> Void)?  // Optional closure for custom refresh action

    func makeUIView(context: Context) -> WKWebView {
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences = preferences
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.isScrollEnabled = true
        webView.scrollView.minimumZoomScale = 3.0
        webView.scrollView.maximumZoomScale = 3.0
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    func makeCoordinator() -> WebViewCoordinator {
        WebViewCoordinator(self, refreshAction: refreshAction)
    }
}

class WebViewCoordinator: NSObject, WKNavigationDelegate {
    var parent: WebView
    var refreshAction: (() -> Void)?
    
    init(_ parent: WebView, refreshAction: (() -> Void)?) {
        self.parent = parent
        self.refreshAction = refreshAction
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.parent.pageTitle = webView.title ?? "No Title"
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("WebView load failed: \(error.localizedDescription)")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("WebView provisional load failed: \(error.localizedDescription)")
    }
}

struct WebViewPreview: View {
    @State private var url = URL(string: "https://www.apple.com")!
    @State private var pageTitle: String = "Loading..."
    
    var body: some View {
        VStack {
            WebView(url: $url, pageTitle: $pageTitle, refreshAction: nil) // No custom action provided; uses default
            .edgesIgnoringSafeArea(.all)
            
            Text(pageTitle)
                .font(.headline)
                .padding()
        }
    }
}

struct WebViewPreview_Previews: PreviewProvider {
    static var previews: some View {
        WebViewPreview()
    }
}
