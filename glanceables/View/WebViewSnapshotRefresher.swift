import SwiftUI
import WebKit
import Combine

struct WebViewSnapshotRefresher: UIViewRepresentable {
    @ObservedObject var viewModel = WebClipManagerViewModel.shared
    @ObservedObject var llamaAPIManager = LlamaAPIManager()
    
    var webClip: WebClip
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        
        configureMessageHandler(webView: webView, contentController: webView.configuration.userContentController, context: context)
        JavaScriptLoader.loadJavaScript(webView: webView, resourceName: "captureElements", extensionType: "js")
        
        context.coordinator.webView = webView
        injectGetElementsFromSelectorsScript(webView: webView)
        
        let request = URLRequest(url: webClip.url)
        webView.load(request)        
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        
    }
    
    func makeCoordinator() -> WebViewCoordinator {
        WebViewCoordinator(self)
    }
    
    private func configureMessageHandler(webView: WKWebView, contentController: WKUserContentController, context: Context) {
        contentController.add(context.coordinator, name: "elementsFromSelectorsHandler")
    }
    
    func injectGetElementsFromSelectorsScript(webView: WKWebView) {
        guard let capturedElement = self.webClip.capturedElements?.last else { return }
        let elementSelector = capturedElement.selector
        JavaScriptLoader.injectGetElementsFromSelectorsScript(webView: webView, elementSelector: elementSelector)
    }
    
    func injectIsolateElementFromSelectorScript(webView: WKWebView) {
        guard let capturedElement = self.webClip.capturedElements?.last else { return }
        let elementSelector = capturedElement.selector
        JavaScriptLoader.injectIsolateElementFromSelectorScript(webView: webView, elementSelector: elementSelector)
    }
}

