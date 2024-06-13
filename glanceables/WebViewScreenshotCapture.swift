import SwiftUI
import WebKit

struct WebViewScreenshotCapture: UIViewRepresentable {
    @Binding var url: URL
    @Binding var pageTitle: String
    @Binding var clipRect: CGRect?
    @Binding var originalSize: CGSize?
    @Binding var screenshot: UIImage?
    @Binding var userInteracting: Bool

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.scrollView.delegate = context.coordinator
        
        configureMessageHandler(webView: webView, contentController: webView.configuration.userContentController, context: context)

        context.coordinator.webView = webView

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if webView.url == nil {
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

    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, UIScrollViewDelegate, WKScriptMessageHandler {
        var parent: WebViewScreenshotCapture
        var webView: WKWebView?

        init(_ parent: WebViewScreenshotCapture) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.parent.pageTitle = webView.title ?? "No Title"
            }
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            // Process message for updated selection
        }

        func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            self.parent.userInteracting = true
        }

        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            if !decelerate {
                self.parent.userInteracting = false
            }
        }

        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            self.parent.userInteracting = false
        }

        func captureScreenshot() {
            guard let webView = webView, let clipRect = parent.clipRect else { return }
            let snapshotConfig = WKSnapshotConfiguration()
            snapshotConfig.rect = clipRect // Using the clipRect to define the snapshot area

            webView.takeSnapshot(with: snapshotConfig) { image, error in
                if let image = image {
                    DispatchQueue.main.async {
                        self.parent.screenshot = image
                    }
                } else if let error = error {
                    print("Screenshot error: \(error.localizedDescription)")
                }
            }
        }
    }
}
