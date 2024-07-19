import SwiftUI
import WebKit
import Combine

struct WebViewSnapshotRefresher: UIViewRepresentable {
    @ObservedObject private var viewModel = WebClipEditorViewModel.shared
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
    
    
    private func configureMessageHandler(webView: WKWebView, contentController: WKUserContentController, context: Context) {
        contentController.add(context.coordinator, name: "elementsFromSelectorsHandler")
    }
    
    
    func injectGetElementsFromSelectorsScript(webView: WKWebView) {
        guard let lastElement = self.item?.capturedElements?.last else { return }
        let elementSelector = lastElement.selector
        let jsCode = """
        (function() {
            function restoreElements() {
                try {
                    const elementSelector = "\(elementSelector)";
                    const elements = document.querySelectorAll(elementSelector);
                    const selectors = Array.from(elements).map(element => {
                        return {selector: elementSelector, text: element.innerText, outerHTML: element.outerHTML};
                    });
                    
                    window.webkit.messageHandlers.elementsFromSelectorsHandler.postMessage(JSON.stringify(selectors));
                } catch (error) {
                    console.error('Error in script:', error);
                    window.webkit.messageHandlers.elementsFromSelectorsHandler.postMessage('Error: ' + error.message);
                }
            }
        
            function watchForElement() {
                const elementSelector = "\(elementSelector)";
                const observer = new MutationObserver((mutationsList, observer) => {
                    const elements = document.querySelectorAll(elementSelector);
                    if (elements.length > 0) {
                        restoreElements();
                        observer.disconnect(); // Stop observing once elements are found
                    }
                });
        
                observer.observe(document.body, { childList: true, subtree: true });
        
                // Check if the elements are already present
                const elements = document.querySelectorAll(elementSelector);
                if (elements.length > 0) {
                    restoreElements();
                    observer.disconnect();
                }
            }
        
            watchForElement();
        })();
        """
        
        webView.configuration.userContentController.addUserScript(WKUserScript(source: jsCode, injectionTime: .atDocumentEnd, forMainFrameOnly: false))
    }
    
    
    
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, UIScrollViewDelegate, WKScriptMessageHandler {
        var parent: WebViewSnapshotRefresher
        var webView: WKWebView?
        var reloadSubscription: AnyCancellable?
        var pageTitle: String?
        
        private var screenshotTrigger = PassthroughSubject<Void, Never>()
        private var cancellables = Set<AnyCancellable>()
        
        init(_ parent: WebViewSnapshotRefresher) {
            self.parent = parent
            super.init()
            
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
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            print("Started loading: \(String(describing: webView.url))")
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("Finished loading: \(String(describing: webView.url))")
            let simplifiedPageTitle = URLUtilities.simplifyPageTitle(webView.title ?? "No Title")
            self.pageTitle = simplifiedPageTitle
            
            if let capturedElements = self.parent.item?.capturedElements  {
                self.restoreScrollPosition(capturedElements, in: webView)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
                // Restore scroll positions based on captured elements
                if let capturedElements = self.parent.item?.capturedElements  {
                    self.restoreScrollPosition(capturedElements, in: webView)
                }
                // Capture a screenshot
                self.screenshotTrigger.send(())
            }
            
            // Subscribe to the reload trigger
            self.reloadSubscription = self.parent.reloadTrigger.sink {
                webView.reload()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.captureScreenshot()
                }
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
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "elementsFromSelectorsHandler", let messageBody = message.body as? String {
                parseElementsFromSelectors(messageBody)
            }
        }
        
        func parseElementsFromSelectors(_ jsonString: String) {
            guard let data = jsonString.data(using: .utf8) else {
                print("Error: Cannot create data from jsonString")
                return
            }
            
            do {
                let elements = try JSONDecoder().decode([HTMLElement].self, from: data)
                processElements(elements)
            } catch {
                print("Error: \(error)")
            }
        }
        
        
        func processElements(_ elements: [HTMLElement]) {
            self.parent.llamaAPIManager.analyzeHTML(htmlElements: elements) { result in
                switch result {
                case .success(let result):
                    print("Generated result: \(result)")
                    // Do something with the generated filename, e.g., update UI or model
                case .failure(let error):
                    print("Error interpreting changes: \(error.localizedDescription)")
                }
            }
        }
        
        func captureScreenshot() {
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

