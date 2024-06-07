import SwiftUI
import WebKit

// WebView wrapper for displaying web content with zoom, scroll, refresh capabilities, and selection support
struct WebView: UIViewRepresentable {
    @Binding var url: URL
    @Binding var pageTitle: String
    @Binding var selectionRectangle: CGRect?  // Optional: Stores the coordinates of the selected area

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
        
        injectSelectionJavaScript(webView)  // Inject JavaScript for selection handling
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    func makeCoordinator() -> WebViewCoordinator {
        WebViewCoordinator(self)
    }

    private func injectSelectionJavaScript(_ webView: WKWebView) {
        // JavaScript code to allow user to select a rectangle and capture its coordinates
        let jsCode = """
        document.addEventListener('mouseup', function(e) {
            var rect = e.target.getBoundingClientRect();
            window.webkit.messageHandlers.selectionHandler.postMessage({
                x: rect.left,
                y: rect.top,
                width: rect.width,
                height: rect.height
            });
        });
        """
        webView.configuration.userContentController.addUserScript(WKUserScript(source: jsCode, injectionTime: .atDocumentEnd, forMainFrameOnly: false))
    }
}

class WebViewCoordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
    var parent: WebView

    init(_ parent: WebView) {
        self.parent = parent
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Capture the title
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.parent.pageTitle = webView.title ?? "No Title"
        }
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "selectionHandler", let dict = message.body as? [String: CGFloat] {
            let rect = CGRect(x: dict["x"]!, y: dict["y"]!, width: dict["width"]!, height: dict["height"]!)
            DispatchQueue.main.async {
                self.parent.selectionRectangle = rect  // Update the selection rectangle binding
            }
        }
    }
}
