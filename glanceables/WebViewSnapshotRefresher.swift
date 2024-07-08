import SwiftUI
import WebKit
import Combine

struct WebViewSnapshotRefresher: UIViewRepresentable {
    @Binding var url: URL
    @Binding var pageTitle: String
    @Binding var clipRect: CGRect?
    @Binding var originalSize: CGSize?
    @Binding var screenshot: UIImage?
    @Binding var item: WebClip
    var reloadTrigger: PassthroughSubject<Void, Never> // Add a reload trigger
    var onScreenshotTaken: ((String) -> Void)?
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        
        context.coordinator.webView = webView
        
        // Subscribe to the reload trigger
        context.coordinator.reloadSubscription = reloadTrigger.sink {
            webView.reload()
        }
        
        return webView
    }
    
    func normalizeURL(_ urlString: String?) -> String? {
        guard let urlString = urlString, var components = URLComponents(string: urlString) else {
            return nil
        }
        
        // Remove the "www." prefix if it exists
        if components.host?.hasPrefix("www.") == true {
            components.host = String(components.host!.dropFirst(4))
        }
        
        // Force the scheme to https
        components.scheme = "https"
        
        // Remove any trailing slash
        if components.path.hasSuffix("/") {
            components.path = String(components.path.dropLast())
        }
        
        return components.string
    }
    
    func urlsAreEqual(_ urlString1: String, _ urlString2: String) -> Bool {
        guard let normalizedURL1 = normalizeURL(urlString1),
              let normalizedURL2 = normalizeURL(urlString2) else {
            return false
        }
        
        return normalizedURL1 == normalizedURL2
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let currentURLString = webView.url?.absoluteString
        let newURLString = url.absoluteString
        
        if normalizeURL(currentURLString) != normalizeURL(newURLString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebViewSnapshotRefresher
        var webView: WKWebView?
        var reloadSubscription: AnyCancellable?
        
        init(_ parent: WebViewSnapshotRefresher) {
            self.parent = parent
        }
        
        deinit {
            reloadSubscription?.cancel()
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let simplifiedPageTitle = URLUtilities.simplifyPageTitle(webView.title ?? "No Title")
                self.parent.pageTitle = simplifiedPageTitle
            }
            
            // Restore scroll positions based on captured elements
            if let elements = self.parent.item.capturedElements {
                self.restoreScrollPosition(elements, in: webView)
            }
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // Capture a screenshot
                self.captureScreenshot()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.1) {
                // Restore scroll positions based on captured elements
                if let elements = self.parent.item.capturedElements {
                    self.restoreScrollPosition(elements, in: webView)
                }
                // Capture a screenshot
                self.captureScreenshot()
            }
            
        }
        
        // Method to restore the scroll position for captured elements
        func restoreScrollPosition(_ elements: [CapturedElement], in webView: WKWebView) {
            // Assuming 'CapturedElement' has properties like 'relativeTop' that can be used for scrolling
            guard let firstElement = elements.first else { return }
            let scrollScript = "window.scrollTo(0, \(firstElement.relativeTop));"
            webView.evaluateJavaScript(scrollScript, completionHandler: { result, error in
                if let error = error {
                    print("Error while trying to scroll: \(error.localizedDescription)")
                }
            })
        }
        
        private func captureScreenshot() {
            guard let webView = webView else { return }
            
            let configuration = WKSnapshotConfiguration()
            if let clipRect = parent.clipRect {
                // Adjust clipRect based on the current zoom scale and content offset
                let zoomScale = webView.scrollView.zoomScale
                let offsetX = webView.scrollView.contentOffset.x
                var y = clipRect.origin.y
                
                if let elements = self.parent.item.capturedElements {
                    if elements.first != nil {
                        y = 0
                    }
                }
                
                let adjustedClipRect = CGRect(
                    x: (clipRect.origin.x + offsetX) / zoomScale,
                    y: y / zoomScale,
                    width: clipRect.size.width / zoomScale,
                    height: clipRect.size.height / zoomScale
                )
                
                configuration.rect = adjustedClipRect
            }
            
            webView.takeSnapshot(with: configuration) { image, error in
                if let image = image {
                    DispatchQueue.main.async {
                        self.parent.screenshot = image
                        if let screenshotPath = ScreenshotUtils.saveScreenshotToLocalDirectory(screenshot: image) {
                            self.parent.onScreenshotTaken?(screenshotPath)
                        }
                    }
                } else if let error = error {
                    print("Screenshot error: \(error.localizedDescription)")
                }
            }
        }
    }
}
