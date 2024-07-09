import SwiftUI
import WebKit

struct WebViewScreenshotCapture: UIViewRepresentable {
    @ObservedObject var viewModel: WebClipEditorViewModel
    
    @Binding var pageTitle: String
    @Binding var clipRect: CGRect?
    
    @Binding var screenshot: UIImage?
    @Binding var userInteracting: Bool
    @Binding var scrollY:Double
    @Binding var capturedElements: [CapturedElement]?
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.scrollView.delegate = context.coordinator
        
        configureMessageHandler(webView: webView, contentController: webView.configuration.userContentController, context: context)
        loadJavaScript(webView: webView)
        injectSelectionScript(webView: webView)
        injectCaptureElementsScript(webView: webView)
        
        
        context.coordinator.webView = webView
        
        return webView
    }
    
    func loadJavaScript(webView: WKWebView) {
        guard let scriptURL = Bundle.main.url(forResource: "captureElements", withExtension: "js"),
              let scriptContent = try? String(contentsOf: scriptURL) else {
            print("Failed to load JavaScript file")
            return
        }
        
        let userScript = WKUserScript(source: scriptContent, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        webView.configuration.userContentController.addUserScript(userScript)
    }
    
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // First, check if webView.url is nil
        if webView.url == nil {
            // Safely unwrap the optional url
            if let validURL = viewModel.validURL {
                // Now you have a non-nil URL, create a URLRequest
                let request = URLRequest(url: validURL)
                webView.load(request)
            }
        }
        // Call the screenshot capturing method on the coordinator
        context.coordinator.debouncedCaptureScreenshot()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func configureMessageHandler(webView: WKWebView, contentController: WKUserContentController, context: Context) {
        contentController.add(context.coordinator, name: "selectionHandler")
        contentController.add(context.coordinator, name: "capturedElementsHandler")
    }
    
    private func injectCaptureElementsScript(webView: WKWebView){
        let jsCode = """
        document.addEventListener('mouseup', function(e) {
            const elements = getElementsWithinBoundary(e.clientX, e.clientY);
            const selectors = elements.map(element => ({
                ...getElementPosition(element),
                selector: getUniqueSelector(element)
            }));
            window.webkit.messageHandlers.capturedElementsHandler.postMessage(JSON.stringify(selectors));
        });
        """
        
        
        webView.configuration.userContentController.addUserScript(WKUserScript(source: jsCode, injectionTime: .atDocumentStart, forMainFrameOnly: false))
    }
    
    private func injectSelectionScript(webView: WKWebView) {
        let jsString = """
            function getCSSSelector(element) {
                let selector = element.tagName.toLowerCase();
                if (element.id) {
                    selector += '#' + element.id;
                } else if (element.className) {
                    const classes = element.className.split(' ').filter(c => c !== '').join('.');
                    if (classes) {
                        selector += '.' + classes;
                    }
                }
                return selector;
            }
        
            document.addEventListener('mousedown', function(e) {
                const rect = e.target.getBoundingClientRect();
                const scrollY = window.pageYOffset || document.documentElement.scrollTop;
                const selector = getCSSSelector(e.target);
                const data = {
                    viewportX: e.clientX, // X coordinate relative to the viewport
                    viewportY: e.clientY, // Y coordinate relative to the viewport
                    documentX: e.clientX + window.pageXOffset, // X coordinate relative to the document
                    documentY: e.clientY + window.pageYOffset, // Y coordinate relative to the document
                    width: rect.width,
                    height: rect.height,
                    scrollY: scrollY,
                    selector: selector
                };
                window.webkit.messageHandlers.selectionHandler.postMessage(JSON.stringify(data));
            });
        
            document.addEventListener('mouseup', function(e) {
                const rect = e.target.getBoundingClientRect();
                const scrollY = window.pageYOffset || document.documentElement.scrollTop;
                const selector = getCSSSelector(e.target);
                const data = {
                    viewportX: e.clientX, // X coordinate relative to the viewport
                    viewportY: e.clientY, // Y coordinate relative to the viewport
                    documentX: e.clientX + window.pageXOffset, // X coordinate relative to the document
                    documentY: e.clientY + window.pageYOffset, // Y coordinate relative to the document
                    width: rect.width,
                    height: rect.height,
                    scrollY: scrollY,
                    mouseup: true,
                    selector: selector
                };
                window.webkit.messageHandlers.selectionHandler.postMessage(JSON.stringify(data));
            });
        """
        webView.configuration.userContentController.addUserScript(WKUserScript(source: jsString, injectionTime: .atDocumentStart, forMainFrameOnly: false))
    }
    
    
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, UIScrollViewDelegate, WKScriptMessageHandler {
        var parent: WebViewScreenshotCapture
        var webView: WKWebView?
        private var screenshotCaptureWorkItem: DispatchWorkItem?
        
        
        init(_ parent: WebViewScreenshotCapture) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let simplifiedPageTitle = URLUtilities.simplifyPageTitle(webView.title ?? "No Title")
                
                self.parent.pageTitle = simplifiedPageTitle
                
                self.captureScreenshot()
                                                
                self.parent.viewModel.saveOriginalSize(newOriginalSize: webView.scrollView.contentSize)                
                
                // Initialize clipRect in the center of the WebView frame
                if self.parent.clipRect == nil, let frame = self.webView?.frame {
                    let rectWidth: CGFloat = 300 // Example width
                    let rectHeight: CGFloat = 300 // Example height
                    let centerX = frame.width / 2 - rectWidth / 2
                    let centerY = frame.height / 2 - rectHeight / 2
                    self.parent.clipRect = CGRect(x: centerX, y: centerY, width: rectWidth, height: rectHeight)
                }
                
            }
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            // Extract the host from the current URL
            let currentHost = self.parent.viewModel.validURL!.host
            
            // Extract the host from the navigation request URL
            if let newUrl = navigationAction.request.url, let newHost = newUrl.host {
                // Update the parent.url only if the domains match
                if newHost == currentHost {
                    DispatchQueue.main.async {
                        self.parent.viewModel.validURL = newUrl
                    }
                } else {
                    //                    print("Domain mismatch. Current domain: \(currentHost ?? "None"), New domain: \(newHost)")
                }
            } else {
                //                print("Invalid or no host found in new URL")
            }
            decisionHandler(.allow)
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "selectionHandler", let messageBody = message.body as? String {
                let data = parseMessage(messageBody)
                let scrollY = parseScrollY(messageBody)
                if scrollY != 0 {
                    DispatchQueue.main.async {
                        self.parent.scrollY = scrollY
                    }
                }
                
            }
            
            if message.name == "capturedElementsHandler", let messageBody = message.body as? String {
                parseCapturedElements(messageBody)
            }
            
        }
        
        func parseCapturedElements(_ jsonString: String) {
            guard let data = jsonString.data(using: .utf8) else {
                print("Error: Cannot create data from jsonString")
                return
            }
            
            do {
                let elements = try JSONDecoder().decode([CapturedElement].self, from: data)
                processCapturedElements(elements)
            } catch {
                print("Error: \(error)")
            }
        }
        
        func processCapturedElements(_ elements: [CapturedElement]) {
            self.parent.capturedElements = elements
        }
        
        private func parseScrollY(_ message: String) -> Double {
            let data = Data(message.utf8)
            
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: CGFloat],
               let scrollY = json["scrollY"] {
                return scrollY
            }
            return 0.0
        }
        
        private func parseMessage(_ message: String) -> CGRect {
            let data = Data(message.utf8)
            
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: CGFloat],
               let x = json["x"], let y = json["y"], let width = json["width"], let height = json["height"] {
                return CGRect(x: x, y: y, width: width, height: height)
            }
            return .zero
        }
        
        
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            DispatchQueue.main.async {
                self.parent.scrollY = Double(scrollView.contentOffset.y)
            }
        }
        
        func debouncedCaptureScreenshot() {
            // Cancel the previous work item if it was scheduled
            screenshotCaptureWorkItem?.cancel()
            
            // Create a new work item to capture the screenshot
            screenshotCaptureWorkItem = DispatchWorkItem { [weak self] in
                self?.captureScreenshot()
            }
            
            // Schedule the new work item after 0.2 seconds
            if let workItem = screenshotCaptureWorkItem {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: workItem)
            }
        }
        
        
        func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            self.parent.userInteracting = true
        }
        
        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            if !decelerate {
                self.parent.userInteracting = false
            }
        }
        
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            self.parent.userInteracting = false
        }
        
        private func captureScreenshot() {
            guard let webView = webView else { return }
            
            let configuration = WKSnapshotConfiguration()
            if let clipRect = parent.clipRect {
                // Capture the current screenshot that the user sees
                let adjustedClipRect = CGRect(
                    x: clipRect.origin.x,
                    y: clipRect.origin.y,
                    width: clipRect.size.width,
                    height: clipRect.size.height
                )
                configuration.rect = adjustedClipRect
            }
            
            webView.takeSnapshot(with: configuration) { image, error in
                if let image = image {
                    DispatchQueue.main.async {
                        self.parent.screenshot = image
                    }
                } else if let error = error {
                    print("Screenshot error: \(error.localizedDescription)")
                }
            }
            
        }
    }
}
