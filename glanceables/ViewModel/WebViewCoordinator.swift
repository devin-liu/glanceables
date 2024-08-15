import SwiftUI
import WebKit
import Combine

class WebViewCoordinator: NSObject, WKNavigationDelegate, WKUIDelegate, UIScrollViewDelegate, WKScriptMessageHandler {
    var parent: WebViewSnapshotRefresher
    var webView: WKWebView?
    var reloadSubscription: AnyCancellable?
    var llamaResult: LlamaResult?
    var webClipManager: WebClipManagerViewModel
    var webClipId: UUID
    var llamaAPIManager: LlamaAPIManager
    
    private var cancellables = Set<AnyCancellable>()
    
    init(_ parent: WebViewSnapshotRefresher, webClipId: UUID, webClipManager: WebClipManagerViewModel, llamaAPIManager: LlamaAPIManager) {
        self.parent = parent
        self.webClipId = webClipId
        self.webClipManager = webClipManager
        self.llamaAPIManager = llamaAPIManager
        super.init()
    }
    
    deinit {
        print("WebViewcoordinator deinit")
        //        schedulerViewModel.stopScheduler()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        let simplifiedPageTitle = URLUtilities.simplifyPageTitle(webView.title ?? "No Title")
        
        if let capturedElements = webClipManager.webClip(webClipId)?.capturedElements  {
            restoreScrollPosition(capturedElements, in: webView)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) { [self] in
            // Restore scroll positions based on captured elements
            if let capturedElements = webClipManager.webClip(webClipId)?.capturedElements  {
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
            captureScreenshot(webView: webView)
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
        llamaAPIManager.analyzeInnerText(innerText: innerText) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let result):
                webClipManager.updateWebClip(withId: webClipId, newLlamaResult: result)
                print("Generated result: \(result)")
                webClipManager.webClip(webClipId)?.queueSnapshotUpdate(innerText: innerText, conciseText: result.conciseText)
            case .failure(let error):
                print("Error interpreting changes: \(error.localizedDescription)")
                webClipManager.webClip(webClipId)?.queueSnapshotUpdate(innerText: innerText, conciseText: innerText)
            }
        }
    }
    
    func captureScreenshot(webView: WKWebView) {
        let webClipManager = webClipManager
        let webClipId = webClipId
        
        let configuration = WKSnapshotConfiguration()
        
        if let clipRect = webClipManager.webClip(webClipId)?.clipRect {
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
                let newSnapshot = webClipManager.updateScreenshot(image, toClipId: webClipId)
                if newSnapshot != nil {
                    webClipManager.webClip(webClipId)?.queueSnapshotUpdate(newSnapshot: newSnapshot)
                }
            }
        }
    }
}
