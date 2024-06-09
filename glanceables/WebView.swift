import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    @Binding var url: URL
    @Binding var pageTitle: String
    @Binding var clipRect: CGRect?

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        configureMessageHandler(webView: webView, contentController: webView.configuration.userContentController, context: context)
        injectSelectionScript(webView: webView)
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        // Only reload the web view if the URL changes
        if webView.url != url {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    private func configureMessageHandler(webView: WKWebView, contentController: WKUserContentController, context: Context) {
        contentController.add(context.coordinator, name: "selectionHandler")
    }

    private func injectSelectionScript(webView: WKWebView) {
        let jsString = """
            document.addEventListener('mouseup', function(e) {
                const rect = e.target.getBoundingClientRect();
                const data = { x: rect.left, y: rect.top, width: rect.width, height: rect.height };
                window.webkit.messageHandlers.selectionHandler.postMessage(JSON.stringify(data));
            });
        """
        webView.configuration.userContentController.addUserScript(WKUserScript(source: jsString, injectionTime: .atDocumentEnd, forMainFrameOnly: false))
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.parent.pageTitle = webView.title ?? "No Title"

                // Adjust the scroll only if clipRect exists
                if let clipRect = self.parent.clipRect {
                    self.scrollToAdjustedClippedArea(webView: webView, clipRect: clipRect, xCorrection: 1.0, yCorrection: 1.0) // Use real correction values
                }
            }
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "selectionHandler", let messageBody = message.body as? String {
                let data = parseMessage(messageBody)
                DispatchQueue.main.async {
                    self.parent.clipRect = data
                }
            }
        }

        private func scrollToAdjustedClippedArea(webView: WKWebView, clipRect: CGRect, xCorrection: CGFloat, yCorrection: CGFloat) {
            let adjustedX = clipRect.origin.x * xCorrection
            let adjustedY = clipRect.origin.y * yCorrection
            let jsString = """
                window.scrollTo({left: \(adjustedX), top: \(adjustedY), behavior: 'smooth'});
            """
            webView.evaluateJavaScript(jsString, completionHandler: nil)
        }

        private func parseMessage(_ message: String) -> CGRect {
            let data = Data(message.utf8)
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: CGFloat],
               let x = json["x"], let y = json["y"], let width = json["width"], let height = json["height"] {
                return CGRect(x: x, y: y, width: width, height: height)
            }
            return .zero
        }
    }
}
