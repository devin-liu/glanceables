import SwiftUI
import WebKit

struct WebViewSnapshotRefresher: UIViewRepresentable {
    var webClipManager: WebClipManagerViewModel
    var webClipId: UUID
    @StateObject var llamaAPIManager = LlamaAPIManager()
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        
        configureMessageHandler(webView: webView, contentController: webView.configuration.userContentController, context: context)
        JavaScriptLoader.loadJavaScript(webView: webView, resourceName: "captureElements", extensionType: "js")
        
        context.coordinator.webView = webView
        injectGetElementsFromSelectorsScript(webView: webView)
        
        let request = URLRequest(url: webClipManager.webClip(webClipId)!.url)
        webView.load(request)
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        print("updateUIView")
    }
    
    func makeCoordinator() -> WebViewCoordinator {
        WebViewCoordinator(self, webClipId: webClipId, llamaAPIManager: llamaAPIManager)
    }
    
    func dismantleUIView(_ uiView: WKWebView, coordinator: WebViewCoordinator) {
        print("dismantleUIView WebViewSnapshotRefresher")
    }
    func viewWillDisappear(){
        print("viewWillDisappear WebViewSnapshotRefresher")
    }
    
    private func configureMessageHandler(webView: WKWebView, contentController: WKUserContentController, context: Context) {
        contentController.add(context.coordinator, name: "elementsFromSelectorsHandler")
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
}

