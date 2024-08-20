import SwiftUI
import WebKit

struct WebViewSnapshotRefresher: UIViewRepresentable {
    @Environment(WebClipManagerViewModel.self) private var webClipManager
    var webClipId: UUID
    var id = UUID()
    @State var llamaAPIManager = LlamaAPIManager()
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        
        
        let leakAvoider = LeakAvoider(delegate: context.coordinator)
        
        context.coordinator.webView = webView
        webView.configuration.userContentController.add(leakAvoider, name: "elementsFromSelectorsHandler")
        
        JavaScriptLoader.loadJavaScript(webView: webView, resourceName: "captureElements", extensionType: "js")        
        injectGetElementsFromSelectorsScript(webView: webView)
        
        let request = URLRequest(url: webClipManager.webClip(webClipId)!.url)
        webView.load(request)
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        print("updateUIView")
    }
    
    func makeCoordinator() -> WebViewCoordinator {
        WebViewCoordinator(self)
    }
    
    func dismantleUIView(_ uiView: WKWebView, coordinator: WebViewCoordinator) {
        print("dismantleUIView WebViewSnapshotRefresher")
    }
    func viewWillDisappear(){
        print("viewWillDisappear WebViewSnapshotRefresher")
    }
    
    func handleDidFinishNavigation(webView: WKWebView){
        if let capturedElements = webClipManager.webClip(webClipId)?.capturedElements  {
            restoreScrollPosition(capturedElements, in: webView)
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
    
    func processElementsInnerText(_ innerText: String) {
        llamaAPIManager.analyzeInnerText(innerText: innerText) { [self] result in
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
    
    func injectGetElementsFromSelectorsScript(webView: WKWebView) {
        guard let capturedElement = webClipManager.webClip(webClipId)?.capturedElements?.last else { return }
        let elementSelector = capturedElement.selector
        JavaScriptLoader.injectGetElementsFromSelectorsScript(webView: webView, elementSelector: elementSelector)
    }
    
    func injectIsolateElementFromSelectorScript(webView: WKWebView) {
        guard let capturedElement = webClipManager.webClip(webClipId)?.capturedElements?.last else { return }
        let elementSelector = capturedElement.selector
        JavaScriptLoader.injectIsolateElementFromSelectorScript(webView: webView, elementSelector: elementSelector)
    }
    
    func captureScreenshot(webView: WKWebView) {
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



