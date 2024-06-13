import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    @Binding var url: URL
    @Binding var pageTitle: String
    @Binding var clipRect: CGRect?
    @Binding var originalSize: CGSize?  // Binding for the original size

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

        // Explicitly set frame size here
        scrollView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 300)
        webView.frame = scrollView.frame

        context.coordinator.webView = webView
        context.coordinator.scrollView = scrollView

        return scrollView
    }

    func updateUIView(_ scrollView: UIScrollView, context: Context) {
        guard let webView = context.coordinator.webView else { return }
        
        if webView.url != url {
            let request = URLRequest(url: url)
            webView.load(request)
        }

        if let clipRect = clipRect {
            scrollView.contentSize = CGSize(width: clipRect.width, height: 300)
            webView.frame = CGRect(origin: .zero, size: scrollView.contentSize)
            context.coordinator.scrollToAdjustedClippedArea(clipRect: clipRect)
        } else {
            scrollView.contentSize = CGSize(width: scrollView.frame.width, height: 300)
            webView.frame = CGRect(origin: .zero, size: CGSize(width: scrollView.frame.width, height: 300))
        }
        
        // Debugging Layout
        print("WebView Frame: \(webView.frame)")
        print("ScrollView Content Size: \(scrollView.contentSize)")
        
        // Update layout immediately
        webView.setNeedsLayout()
        webView.layoutIfNeeded()
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
        var scrollView: UIScrollView?

        init(_ parent: WebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.parent.pageTitle = webView.title ?? "No Title"

                if let clipRect = self.parent.clipRect {
                    self.scrollToAdjustedClippedArea(clipRect: clipRect)
                }
                // Store the original size of the web view
//                self.parent.originalSize = webView.scrollView.contentSize
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

        func scrollToAdjustedClippedArea(clipRect: CGRect) {
            guard let scrollView = scrollView else { return }
            scrollView.setContentOffset(CGPoint(x: clipRect.origin.x, y: clipRect.origin.y), animated: true)
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
