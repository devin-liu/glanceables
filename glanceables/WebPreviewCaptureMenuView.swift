import SwiftUI
import WebKit

struct WebPreviewCaptureMenuView: UIViewRepresentable {
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
        
        // Enable zoom
        webView.scrollView.isScrollEnabled = true
        webView.scrollView.minimumZoomScale = 0.5
        webView.scrollView.maximumZoomScale = 3.0
        webView.scrollView.zoomScale = 1.0
        webView.scrollView.bouncesZoom = true
        
        configureMessageHandler(webView: webView, contentController: webView.configuration.userContentController, context: context)
//        injectSelectionScript(webView: webView)

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

//    private func injectSelectionScript(webView: WKWebView) {
//        let jsString = """
//            document.addEventListener('mouseup', function(e) {
//                const rect = e.target.getBoundingClientRect();
//                const data = { x: rect.left, y: rect.top, width: rect.width, height: rect.height };
//                window.webkit.messageHandlers.selectionHandler.postMessage(JSON.stringify(data));
//            });
//        """
//        webView.configuration.userContentController.addUserScript(WKUserScript(source: jsString, injectionTime: .atDocumentEnd, forMainFrameOnly: false))
//    }

    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, UIScrollViewDelegate, WKScriptMessageHandler {
        var parent: WebPreviewCaptureMenuView
        var webView: WKWebView?

        init(_ parent: WebPreviewCaptureMenuView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.parent.pageTitle = webView.title ?? "No Title"
                
                self.captureScreenshot()
                
                // Initialize clipRect in the center of the WebView frame
                if self.parent.clipRect == nil, let frame = self.webView?.frame {
                    let rectWidth: CGFloat = 300 // Example width
                    let rectHeight: CGFloat = 300 // Example height
                    let centerX = frame.width / 2 - rectWidth / 2
                    let centerY = frame.height / 2 - rectHeight / 2
                    self.parent.clipRect = CGRect(x: centerX, y: centerY, width: rectWidth, height: rectHeight)
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

        private func parseMessage(_ message: String) -> CGRect {
            let data = Data(message.utf8)
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: CGFloat],
               let x = json["x"], let y = json["y"], let width = json["width"], let height = json["height"] {
                return CGRect(x: x, y: y, width: width, height: height)
            }
            return .zero
        }
        
        private func captureScreenshot() {
            guard let webView = webView else { return }

            let configuration = WKSnapshotConfiguration()
            if let clipRect = parent.clipRect {
                // Adjust clipRect based on the current zoom scale and content offset
                let zoomScale = webView.scrollView.zoomScale
                let offsetX = webView.scrollView.contentOffset.x
                let offsetY = webView.scrollView.contentOffset.y

                // Apply the zoom and offset to the clipRect
                let adjustedClipRect = CGRect(
                    x: (clipRect.origin.x + offsetX) / zoomScale,
                    y: (clipRect.origin.y + offsetY) / zoomScale,
                    width: clipRect.size.width / zoomScale,
                    height: clipRect.size.height / zoomScale
                )
                configuration.rect = adjustedClipRect
            }

            webView.takeSnapshot(with: configuration) { image, error in
                if let image = image {
                    DispatchQueue.main.async {
                        // Crop the image to the clipRect
                        if let clipRect = self.parent.clipRect, let croppedImage = image.cgImage?.cropping(to: clipRect) {
                            self.parent.screenshot = UIImage(cgImage: croppedImage)
                        } else {
                            self.parent.screenshot = image
                        }
                    }
                } else if let error = error {
                    print("Screenshot error: \(error.localizedDescription)")
                }
            }
        }

    }
}
