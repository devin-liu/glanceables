import SwiftUI
import WebKit
import Combine

class WebViewCoordinator: NSObject, WKNavigationDelegate, WKUIDelegate, UIScrollViewDelegate, WKScriptMessageHandler {
    var parent: WebViewSnapshotRefresher
    var webView: WKWebView?
    var reloadSubscription: AnyCancellable?
    var llamaResult: LlamaResult?
    var webClipManager: WebClipManagerViewModel
    var webClip: WebClip
    var llamaAPIManager: LlamaAPIManager
    
    private var cancellables = Set<AnyCancellable>()
    
    init(_ parent: WebViewSnapshotRefresher, webClip: WebClip, webClipManager: WebClipManagerViewModel, llamaAPIManager: LlamaAPIManager) {
        self.parent = parent
        self.webClip = webClip
        self.webClipManager = webClipManager
        self.llamaAPIManager = llamaAPIManager
        super.init()
    }
    
    deinit {
        print("WebViewcoordinator deinit")
        //        schedulerViewModel.stopScheduler()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let simplifiedPageTitle = URLUtilities.simplifyPageTitle(webView.title ?? "No Title")
        
        if let capturedElements = webClip.capturedElements  {
            restoreScrollPosition(capturedElements, in: webView)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) { [self] in
            // Restore scroll positions based on captured elements
            if let capturedElements = webClip.capturedElements  {
                restoreScrollPosition(capturedElements, in: webView)
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
        guard let webView = webView else { return }
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
        guard let webClip = parent.webClip else { return }
        llamaAPIManager.analyzeInnerText(innerText: innerText) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let result):
                webClipManager.updateWebClip(withId: webClip.id, newLlamaResult: result)
                print("Generated result: \(result)")
                webClip.queueSnapshotUpdate(innerText: innerText, conciseText: result.conciseText)
            case .failure(let error):
                print("Error interpreting changes: \(error.localizedDescription)")
                webClip.queueSnapshotUpdate(innerText: innerText, conciseText: innerText)
            }
        }
    }
    
    func captureScreenshot() {
        guard let webView = webView else { return }
        guard let webClip = parent.webClip else { return }
        let webClipManager = webClipManager
        
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
                let newSnapshot = webClipManager.updateScreenshot(image, toClip: webClip)
                if newSnapshot != nil {
                    webClip.queueSnapshotUpdate(newSnapshot: newSnapshot)
                }
            }
        }
    }
}
