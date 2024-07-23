import SwiftUI
import WebKit
import Combine

struct WebViewSnapshotRefresher: UIViewRepresentable {
    @ObservedObject var viewModel = WebClipEditorViewModel.shared
    @ObservedObject var llamaAPIManager = LlamaAPIManager()
    let id: UUID
    var reloadTrigger: PassthroughSubject<Void, Never> // Add a reload trigger
    
    var item: WebClip? {
        viewModel.webClip(withId: id)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        
        configureMessageHandler(webView: webView, contentController: webView.configuration.userContentController, context: context)
        JavaScriptLoader.loadJavaScript(webView: webView, resourceName: "captureElements", extensionType: "js")
        
        context.coordinator.webView = webView
        injectGetElementsFromSelectorsScript(webView: webView)
        
        if let webClip = viewModel.webClip(withId: id) {
            let request = URLRequest(url: webClip.url)
            webView.load(request)
        }
        
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
        guard let capturedElement = self.item?.capturedElements?.first else { return }
        let elementSelector = capturedElement.selector
        JavaScriptLoader.injectGetElementsFromSelectorsScript(webView: webView, elementSelector: elementSelector)
    }
}

