import SwiftUI
import WebKit
import Combine

struct WebViewSnapshotRefresher: UIViewRepresentable {
    @Environment(WebClipManagerViewModel.self) private var webClipManager
    var webClipId: UUID
    var llamaAPIManager = LlamaAPIManager()
    @State private var schedulerViewModel = SchedulerViewModel()
    var updaterViewModel: WebClipUpdaterViewModel
    
    init(webClipId: UUID, updaterViewModel: WebClipUpdaterViewModel) {
        self.webClipId = webClipId
        self.updaterViewModel = updaterViewModel
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        
        let coordinator = context.coordinator
        webView.navigationDelegate = coordinator
        webView.uiDelegate = coordinator
        webView.scrollView.delegate = coordinator
        
        
        let leakAvoider = LeakAvoider(delegate: context.coordinator)
        
        context.coordinator.webView = webView
        
        configureMessageHandler(webView: webView, contentController: webView.configuration.userContentController, leakAvoider: leakAvoider)
        
        
        JavaScriptLoader.loadJavaScript(userContentController: webView.configuration.userContentController, resourceName: "captureElements", extensionType: "js")
        injectGetElementsFromSelectorsScript(userContentController: webView.configuration.userContentController)
        
        
        let request = URLRequest(url: webClipManager.webClip(webClipId)!.url)
        webView.load(request)
        
        schedulerViewModel.configure(
            interval: 60.0, // Reload every minute
            actions: { [] schedulerViewModel in
                return (
                    { captureScreenshot(webView: webView) },
                    { webView.reload() }
                )
            }
        )
        
        schedulerViewModel.startScheduler()
        
        return webView
    }
    
    private func configureMessageHandler(webView: WKWebView, contentController: WKUserContentController, leakAvoider: LeakAvoider) {
        contentController.removeAllScriptMessageHandlers()
        contentController.add(leakAvoider, name: "capturedElementsHandler")
        contentController.add(leakAvoider, name: "elementsFromSelectorsHandler")
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        print("updateUIView")
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        print("dismantleUIView WebViewSnapshotRefresher")
        schedulerViewModel.stopScheduler()
        
    }
    func viewWillDisappear(){
        print("viewWillDisappear WebViewSnapshotRefresher")
        schedulerViewModel.stopScheduler()
    }
    
    func handleDidFinishNavigation(webView: WKWebView?){
        guard let webView else { return }
        if let capturedElements = webClipManager.webClip(webClipId)?.capturedElements  {
            restoreScrollPosition(capturedElements, in: webView)
        }
    }
    
    // Method to restore the scroll position for captured elements
    func restoreScrollPosition(_ elements: [CapturedElement], in webView: WKWebView) {
        // Assuming 'CapturedElement' has properties like 'relativeTop' that can be used for scrolling
        guard let firstElement = elements.first else { return }
        
        print("firstelement \(firstElement.selector) | top \(firstElement.relativeTop)")
        
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
        updaterViewModel.queueSnapshotUpdate(innerText: innerText, conciseText: innerText)
        llamaAPIManager.analyzeInnerText(innerText: innerText) { [self] result in
            switch result {
            case .success(let result):
                webClipManager.updateWebClip(withId: webClipId, newLlamaResult: result)
                print("Generated result: \(result)")
                updaterViewModel.queueSnapshotUpdate(innerText: innerText, conciseText: result.conciseText)
            case .failure(let error):
                print("Error interpreting changes: \(error.localizedDescription)")
            }
        }
    }
    
    func injectGetElementsFromSelectorsScript(userContentController: WKUserContentController) {
        guard let capturedElement = webClipManager.webClip(webClipId)?.capturedElements?.first else { return }
        let elementSelector = capturedElement.selector
        JavaScriptLoader.injectGetElementsFromSelectorsScript(userContentController: userContentController, elementSelector: elementSelector)
    }
    
    func injectIsolateElementFromSelectorScript(webView: WKWebView) {
        guard let capturedElement = webClipManager.webClip(webClipId)?.capturedElements?.last else { return }
        let elementSelector = capturedElement.selector
        JavaScriptLoader.injectIsolateElementFromSelectorScript(webView: webView, elementSelector: elementSelector)
    }
    
    func captureScreenshot(webView: WKWebView?) {
        guard let webView else { return }
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
                    updaterViewModel.queueSnapshotUpdate(newSnapshot: newSnapshot)
                }
            }
        }
    }
    
    
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, UIScrollViewDelegate, WKScriptMessageHandler {
        var parent: WebViewSnapshotRefresher
        weak var webView: WKWebView?
        
        private var cancellables = Set<AnyCancellable>()
        
        init(_ parent: WebViewSnapshotRefresher) {
            self.parent = parent
        }
        
        deinit {
            // Print to console that the coordinator is being deinitialized
            print("Snapshot WebViewCoordinator deinitialized")
            
            // Remove any script message handlers
            webView?.configuration.userContentController.removeScriptMessageHandler(forName: "elementsFromSelectorsHandler")
            
            // Cancel all active Combine subscriptions
            cancellables.forEach { $0.cancel() }
            cancellables.removeAll()
            
            // Clear the webView's delegate to avoid retain cycles
            webView?.navigationDelegate = nil
            webView?.uiDelegate = nil
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!
        ) {
            
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.handleDidFinishNavigation(webView: webView)
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard let webView = webView else { return }
            if message.name == "elementsFromSelectorsHandler", let messageBody = message.body as? String {
                parseElementsFromSelectors(messageBody)
                parent.captureScreenshot(webView: webView)
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
                    parent.processElementsInnerText(innerText)
                }
                
            } catch {
                print("Error: \(error)")
            }
        }
        
    }
}
