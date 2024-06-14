import SwiftUI
import WebKit

struct WebViewSnapshotRefresher: UIViewRepresentable {
    @Binding var url: URL
    @Binding var pageTitle: String
    @Binding var clipRect: CGRect?
    @Binding var originalSize: CGSize?
    @Binding var screenshot: UIImage?
    @Binding var scrollPosition: CGPoint?

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.scrollView.delegate = context.coordinator
        
        context.coordinator.webView = webView

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if webView.url != url {
            let request = URLRequest(url: url)
            webView.load(request)
        }

        // Debugging Layout
        print("WebView Frame: \(webView.frame)")
        
        // Update layout immediately
        webView.setNeedsLayout()
        webView.layoutIfNeeded()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate, UIScrollViewDelegate {
        var parent: WebViewSnapshotRefresher
        var webView: WKWebView?

        init(_ parent: WebViewSnapshotRefresher) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.parent.pageTitle = webView.title ?? "No Title"
                self.checkContentLoaded(webView: webView)
            }
        }

        private func checkContentLoaded(webView: WKWebView) {
            webView.evaluateJavaScript("document.readyState") { result, error in
                if let readyState = result as? String, readyState == "complete" {
                    print("Content fully loaded")
                    self.scrollToSavedPosition()
                } else {
                    print("Content not fully loaded, retrying...")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.checkContentLoaded(webView: webView)
                    }
                }
            }
        }

        private func scrollToSavedPosition() {
            guard let webView = webView, let scrollPosition = parent.scrollPosition else { return }
            
            // Scroll to the saved scroll position
            webView.scrollView.setContentOffset(scrollPosition, animated: false)

            // Wait for scrolling to complete
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.captureScreenshot()
            }
        }

        private func captureScreenshot() {
            guard let webView = webView, let clipRect = parent.clipRect else { return }

            // Debugging
            print("Taking snapshot with clipRect: \(clipRect)")

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
