import SwiftUI
import WebKit
import Combine

class WebViewCoordinator: NSObject, WKNavigationDelegate, WKUIDelegate, UIScrollViewDelegate, WKScriptMessageHandler {
    var parent: WebViewSnapshotRefresher
    var webView: WKWebView?
    var reloadSubscription: AnyCancellable?
    var pageTitle: String?
    var llamaResult: LlamaResult?
    
    private var screenshotTrigger = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    init(_ parent: WebViewSnapshotRefresher) {
        self.parent = parent
        super.init()
        self.pageTitle = parent.viewModel.pageTitle
        
        // Configure the throttle for screenshotTrigger
        screenshotTrigger
            .throttle(for: .seconds(60), scheduler: RunLoop.main, latest: true)
            .sink { [weak self] in
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self?.captureScreenshot()
                }
            }
            .store(in: &cancellables)
    }
    
    deinit {
        reloadSubscription?.cancel()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let simplifiedPageTitle = URLUtilities.simplifyPageTitle(webView.title ?? "No Title")
        self.pageTitle = simplifiedPageTitle
        
        if let capturedElements = self.parent.webClip.capturedElements  {
            self.restoreScrollPosition(capturedElements, in: webView)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            // Restore scroll positions based on captured elements
            if let capturedElements = self.parent.webClip.capturedElements  {
                self.restoreScrollPosition(capturedElements, in: webView)
            }
            // Capture a screenshot
            self.screenshotTrigger.send(())
        }
        
        // Subscribe to the reload trigger
        self.reloadSubscription = self.parent.reloadTrigger.sink {
            webView.reload()
            DispatchQueue.main.asyncAfter(deadline: .now() + 60) {
                self.captureScreenshot()
            }
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
        self.parent.llamaAPIManager.analyzeInnerText(innerText: innerText) { result in
            switch result {
            case .success(let result):
                self.parent.viewModel.updateWebClip(withId: self.parent.webClip.id, newLlamaResult: result)
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
        let webClip = self.parent.webClip
        
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
                let newSnapshot = self.parent.viewModel.saveScreenShot(image, toClip: self.parent.webClip)
                if newSnapshot != nil {
                    self.parent.webClip.queueSnapshotUpdate(newSnapshot: newSnapshot)
                }
            }
        }
    }
}
