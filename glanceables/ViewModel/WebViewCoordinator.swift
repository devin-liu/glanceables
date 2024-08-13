import SwiftUI
import WebKit
import Combine

class WebViewCoordinator: NSObject, WKNavigationDelegate, WKUIDelegate, UIScrollViewDelegate, WKScriptMessageHandler {
    var parent: WebViewSnapshotRefresher
    var webView: WKWebView?
    var reloadSubscription: AnyCancellable?
    var pageTitle: String?
    var llamaResult: LlamaResult?
    var webClipManager: WebClipManagerViewModel
    @ObservedObject var webClip: WebClip
    @ObservedObject var llamaAPIManager = LlamaAPIManager()
    
    private var cancellables = Set<AnyCancellable>()
    
    init(_ parent: WebViewSnapshotRefresher, webClip: WebClip, webClipManager: WebClipManagerViewModel) {
        self.parent = parent
        self.webClip = webClip
        self.webClipManager = webClipManager
        self.pageTitle = webClip.pageTitle
        super.init()
    }
    
    deinit {
        print("WebViewcoordinator deinit")
//        schedulerViewModel.stopScheduler()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let simplifiedPageTitle = URLUtilities.simplifyPageTitle(webView.title ?? "No Title")
        self.pageTitle = simplifiedPageTitle
        
        if let capturedElements = webClip.capturedElements  {
            self.restoreScrollPosition(capturedElements, in: webView)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) { [self] in
            // Restore scroll positions based on captured elements
            if let capturedElements = webClip.capturedElements  {
                self.restoreScrollPosition(capturedElements, in: webView)
            }
            // Capture a screenshot
//            self.schedulerViewModel.triggerScreenshot()
        }                
    }
    
    // Method to restore the scroll position for captured elements
    func restoreScrollPosition(_ elements: [CapturedElement], in webView: WKWebView) {
        // Assuming 'CapturedElement' has properties like 'relativeTop' that can be used for scrolling
        guard let firstElement = elements.first else { return }
        
        let scrollScript = """
        scrollToElementWithRelativeTop("\(firstElement.selector)", \(firstElement.relativeTop));
        """
        
        webView.evaluateJavaScript(scrollScript, completionHandler: { result, error in
            if let error = error {
                print("Error while trying to scroll: \(error.localizedDescription)")
            }
        })
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "elementsFromSelectorsHandler", let messageBody = message.body as? String {
            parseElementsFromSelectors(messageBody)
            captureScreenshot()
        }
    }
    
    func parseElementsFromSelectors(_ jsonString: String) {
        guard let data = jsonString.data(using: .utf8) else {
            print("Error: Cannot create data from jsonString")
            return
        }
        
        do {
            let elements = try JSONDecoder().decode([HTMLElement].self, from: data)
            if let innerText = elements.first?.innerText {
                print("InnerText result: ", innerText)
                processElementsInnerText(innerText)
            }
            
        } catch {
            print("Error: \(error)")
        }
    }
    
    
    func processElementsInnerText(_ innerText: String) {
        llamaAPIManager.analyzeInnerText(innerText: innerText) { result in
            switch result {
            case .success(let result):
                self.webClipManager.updateWebClip(withId: self.parent.webClip.id, newLlamaResult: result)
                print("Generated result: \(result)")
                self.parent.webClip.queueSnapshotUpdate(innerText: innerText, conciseText: result.conciseText)
                // Do something with the generated filename, e.g., update UI or model
            case .failure(let error):
                print("Error interpreting changes: \(error.localizedDescription)")
                self.parent.webClip.queueSnapshotUpdate(innerText: innerText, conciseText: innerText)
            }
        }
    }
    
    func captureScreenshot() {
        guard let webView = webView else { return }
        
        let configuration = WKSnapshotConfiguration()
        
        if let clipRect = webClip.clipRect {
            // Adjust clipRect based on the current zoom scale and content offset
            let zoomScale = webView.scrollView.zoomScale
            let offsetX = webView.scrollView.contentOffset.x
            let y = clipRect.origin.y
            
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
                let newSnapshot = self.webClipManager.updateScreenshot(image, toClip: self.webClip)
                if newSnapshot != nil {
                    self.parent.webClip.queueSnapshotUpdate(newSnapshot: newSnapshot)
                }
            }
        }
    }
}
