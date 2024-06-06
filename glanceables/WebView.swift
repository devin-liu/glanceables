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
        webView.scrollView.minimumZoomScale = 1.0
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
        // Delay accessing webView.title to ensure it's updated
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let title = webView.title, !title.isEmpty  {
                self.parent.pageTitle = title
            } else {
                self.parent.pageTitle = "No Title"
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("WebView load failed: \(error.localizedDescription)")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("WebView provisional load failed: \(error.localizedDescription)")
    }
}
