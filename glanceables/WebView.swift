import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    @Binding var url: URL
    @Binding var pageTitle: String
    @Binding var clipRect: CGRect?

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        configureMessageHandler(webView: webView, contentController: webView.configuration.userContentController, context: context)
        injectSelectionScript(webView: webView)

        scrollView.addSubview(webView)
        scrollView.delegate = context.coordinator
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 1.0

        context.coordinator.webView = webView

        return scrollView
    }

    func updateUIView(_ scrollView: UIScrollView, context: Context) {
        guard let webView = context.coordinator.webView else { return }
        
        if webView.url != url {
            let request = URLRequest(url: url)
            webView.load(request)
        }

        if let clipRect = clipRect {
            scrollView.contentSize = CGSize(width: clipRect.width, height: clipRect.height)
            webView.frame = CGRect(origin: .zero, size: scrollView.contentSize)
        } else {
            // If clipRect is not set, fit the web view to the scroll view
            scrollView.contentSize = scrollView.bounds.size
            webView.frame = CGRect(origin: .zero, size: scrollView.bounds.size)
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

    class Coordinator: NSObject, WKNavigationDelegate, UIScrollViewDelegate, WKScriptMessageHandler {
        var parent: WebView
        var webView: WKWebView?

        init(_ parent: WebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.parent.pageTitle = webView.title ?? "No Title"

                // Adjust the web view frame only if clipRect exists
                if let clipRect = self.parent.clipRect {
                    self.adjustWebViewFrame(webView: webView, clipRect: clipRect)
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

        private func adjustWebViewFrame(webView: WKWebView, clipRect: CGRect) {
            webView.frame = CGRect(origin: .zero, size: CGSize(width: clipRect.width, height: clipRect.height))
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
