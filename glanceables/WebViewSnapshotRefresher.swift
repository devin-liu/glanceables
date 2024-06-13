import SwiftUI
import WebKit

struct WebViewSnapshotRefresher: UIViewRepresentable {
    @Binding var url: URL
    @Binding var pageTitle: String
    @Binding var clipRect: CGRect?
    @Binding var originalSize: CGSize?
    @Binding var screenshot: UIImage?

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        
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

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebViewSnapshotRefresher
        var webView: WKWebView?

        init(_ parent: WebViewSnapshotRefresher) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.parent.pageTitle = webView.title ?? "No Title"

                // Capture a screenshot
                self.captureScreenshot()
            }
        }

        private func captureScreenshot() {
            guard let webView = webView else { return }
            webView.takeSnapshot(with: nil) { image, error in
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
