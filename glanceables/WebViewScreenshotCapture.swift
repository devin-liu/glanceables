import SwiftUI
import WebKit

struct WebViewScreenshotCapture: UIViewRepresentable {
    @Binding var url: URL?
    @Binding var pageTitle: String
    @Binding var clipRect: CGRect?
    @Binding var originalSize: CGSize?
    @Binding var screenshot: UIImage?
    @Binding var userInteracting: Bool
    @Binding var scrollY:Double
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.scrollView.delegate = context.coordinator
        
        // Enable zoom
        //        webView.scrollView.isScrollEnabled = true
        //        webView.scrollView.minimumZoomScale = 0.5
        //        webView.scrollView.maximumZoomScale = 3.0
        //        webView.scrollView.zoomScale = 1.0
        //        webView.scrollView.bouncesZoom = true        
        
        context.coordinator.webView = webView
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // First, check if webView.url is nil
        if webView.url == nil {
            // Safely unwrap the optional url
            if let validURL = url {
                // Now you have a non-nil URL, create a URLRequest
                let request = URLRequest(url: validURL)
                webView.load(request)
            }
        }
        // Call the screenshot capturing method on the coordinator
        context.coordinator.debouncedCaptureScreenshot()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, UIScrollViewDelegate, WKScriptMessageHandler {
        var parent: WebViewScreenshotCapture
        var webView: WKWebView?
        private var screenshotCaptureWorkItem: DispatchWorkItem?
        
        
        init(_ parent: WebViewScreenshotCapture) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let simplifiedPageTitle = URLUtilities.simplifyPageTitle(webView.title ?? "No Title")
                
                self.parent.pageTitle = simplifiedPageTitle
                
                self.captureScreenshot()
                
                if self.parent.originalSize == nil {
                    print("webView.scrollView.contentSize",webView.scrollView.contentSize)
                    print("webView.frame.size",webView.frame.size)
                    self.parent.originalSize = webView.scrollView.contentSize
                }
                
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
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            // Extract the host from the current URL
            let currentHost = self.parent.url!.host
            
            // Extract the host from the navigation request URL
            if let newUrl = navigationAction.request.url, let newHost = newUrl.host {
                print("NEW URL", newUrl)
                // Update the parent.url only if the domains match
                if newHost == currentHost {
                    DispatchQueue.main.async {
                        self.parent.url = newUrl
                    }
                } else {
                    print("Domain mismatch. Current domain: \(currentHost ?? "None"), New domain: \(newHost)")
                }
            } else {
                print("Invalid or no host found in new URL")
            }
            decisionHandler(.allow)
        }
        
        
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            DispatchQueue.main.async {
                self.parent.scrollY = Double(scrollView.contentOffset.y)
            }
        }
        
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            
        }
        
        func debouncedCaptureScreenshot() {
            // Cancel the previous work item if it was scheduled
            screenshotCaptureWorkItem?.cancel()
            
            // Create a new work item to capture the screenshot
            screenshotCaptureWorkItem = DispatchWorkItem { [weak self] in
                self?.captureScreenshot()
            }
            
            // Schedule the new work item after 0.2 seconds
            if let workItem = screenshotCaptureWorkItem {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: workItem)
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
                
                // Capture the current screenshot that the user sees
                let adjustedClipRect = CGRect(
                    x: clipRect.origin.x,
                    y: clipRect.origin.y,
                    width: clipRect.size.width,
                    height: clipRect.size.height
                )
                configuration.rect = adjustedClipRect
            }
            
            webView.takeSnapshot(with: configuration) { image, error in
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
