import SwiftUI
import WebKit
import Combine

struct WebViewSnapshotRefresher: UIViewRepresentable {
    @ObservedObject private var viewModel = WebClipEditorViewModel.shared
    let id: UUID
    var reloadTrigger: PassthroughSubject<Void, Never> // Add a reload trigger
    
    private var item: WebClip? {
        viewModel.webClip(withId: id)
    }
    
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
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        if let webClip = viewModel.webClip(withId: id) {
            let newURLString = webClip.url.absoluteString
            if webView.url?.absoluteString != newURLString {
                let request = URLRequest(url: webClip.url)
                webView.load(request)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebViewSnapshotRefresher
        var webView: WKWebView?
        var reloadSubscription: AnyCancellable?
        var pageTitle: String?
        
        init(_ parent: WebViewSnapshotRefresher) {
            self.parent = parent
        }
        
        deinit {
            reloadSubscription?.cancel()
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            
            let simplifiedPageTitle = URLUtilities.simplifyPageTitle(webView.title ?? "No Title")
            self.pageTitle = simplifiedPageTitle
            
            if let capturedElements = self.parent.item?.capturedElements  {
                self.restoreScrollPosition(capturedElements, in: webView)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.1) {
                // Restore scroll positions based on captured elements
                if let capturedElements = self.parent.item?.capturedElements  {
                    self.restoreScrollPosition(capturedElements, in: webView)
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
            guard let item = self.parent.item else { return }
            
            let configuration = WKSnapshotConfiguration()
            if let clipRect = item.clipRect {
                // Adjust clipRect based on the current zoom scale and content offset
                let zoomScale = webView.scrollView.zoomScale
                let offsetX = webView.scrollView.contentOffset.x
                var y = clipRect.origin.y
                
                if let elements = item.capturedElements {
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
                    if let newScreenshotPath = ScreenshotUtils.saveScreenshotToFile(using: item, from: image) {
                        if let item = self.parent.item {
                            let newPageTitle = self.pageTitle ?? item.pageTitle ?? "Loading..."
                            self.parent.viewModel.updateWebClip(withId: item.id,
                                                                newURL: item.url,
                                                                newClipRect: item.clipRect,
                                                                newScreenshotPath: newScreenshotPath,
                                                                newPageTitle: newPageTitle
                            )
                        }
                    }
                }
            }
        }
    }
}

