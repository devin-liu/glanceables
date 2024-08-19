import SwiftUI
import WebKit

struct WebViewScreenshotCapture: UIViewRepresentable {
    //    @Binding var webView: WKWebView?
    
    var viewModel: WebClipCreatorViewModel
    var captureMenuViewModel: WebClipSelectorViewModel
    
    var validURL: URL
    
    func makeUIView(context: Context) -> WKWebView {
        print("makeUIView", validURL)
        let web = WKWebView()
        //        webView = web  // Set the binding
        configureWebView(webView: web, context: context)
        return web
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Perform any dynamic updates to your view's content.
    }
    
    func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        // Remove observers when the view is dismantled.
        //        uiView.removeObserver(coordinator, forKeyPath: #keyPath(WKWebView.title))
        //        uiView.removeObserver(coordinator, forKeyPath: #keyPath(WKWebView.canGoBack))
        //        uiView.removeObserver(coordinator, forKeyPath: #keyPath(WKWebView.canGoForward))
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    private func configureWebView(webView: WKWebView, context: Context) {
        
        let coordinator = context.coordinator
        webView.navigationDelegate = coordinator
        webView.uiDelegate = coordinator
        webView.scrollView.delegate = coordinator
        
        context.coordinator.webView = webView
        
        
        // Observers Setup
        //        webView.addObserver(coordinator, forKeyPath: #keyPath(WKWebView.title), options: .new, context: nil)
        //        webView.addObserver(coordinator, forKeyPath: #keyPath(WKWebView.canGoBack), options: .new, context: nil)
        //        webView.addObserver(coordinator, forKeyPath: #keyPath(WKWebView.canGoForward), options: .new, context: nil)
        //        
        configureMessageHandler(webView: webView, contentController: webView.configuration.userContentController, context: context)
        JavaScriptLoader.loadJavaScript(webView: webView, resourceName: "captureElements", extensionType: "js")
        injectSelectionScript(webView: webView)
        injectCaptureElementsScript(webView: webView)
        
        let request = URLRequest(url: validURL)
        webView.load(request)
    }
    
    
    private func configureMessageHandler(webView: WKWebView, contentController: WKUserContentController, context: Context) {
        contentController.removeAllScriptMessageHandlers()
        contentController.add(context.coordinator, name: "selectionHandler")
        contentController.add(context.coordinator, name: "capturedElementsHandler")
        contentController.add(context.coordinator, name: "userStoppedInteracting")
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
                window.webkit.messageHandlers.userStoppedInteracting.postMessage(null);
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
        
        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            guard let webView = object as? WKWebView else { return }
            if keyPath == #keyPath(WKWebView.title) {
                
                // Update any relevant state in your SwiftUI view model.
                print("observeValue ", webView.title)
                initializeClipRect()
                
            }
        }
        
        deinit {
            webView?.navigationDelegate = nil
            webView?.uiDelegate = nil
            webView?.scrollView.delegate = nil
            
            // Clean up message handlers to ensure they are not retaining this Coordinator
            webView?.configuration.userContentController.removeScriptMessageHandler(forName: "selectionHandler")
            webView?.configuration.userContentController.removeScriptMessageHandler(forName: "capturedElementsHandler")
            webView?.configuration.userContentController.removeScriptMessageHandler(forName: "userStoppedInteracting")
            print("Coordinator is being deinitialized")
        }
        
        func initializeClipRect(){
            if parent.viewModel.currentClipRect == nil, let frame = webView?.frame {
                print("webView ClipRect 2")
                let rectWidth: CGFloat = 300 // Example width
                let rectHeight: CGFloat = 300 // Example height
                let centerX = frame.width / 2 - rectWidth / 2
                let centerY = frame.height / 2 - rectHeight / 2
                parent.viewModel.updateClipRect(newRect: CGRect(x: centerX, y: centerY, width: rectWidth, height: rectHeight))
            }
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!
        ) {
            print("webView ClipRect 1", parent.viewModel.currentClipRect, webView.frame)
            print("WebView didstartNavigation ", webView.title)
            // Initialize clipRect in the center of the WebView frame
            if parent.viewModel.currentClipRect == nil {
                print("webView ClipRect 2")
                let rectWidth: CGFloat = 300 // Example width
                let rectHeight: CGFloat = 300 // Example height
                let centerX = webView.frame.width / 2 - rectWidth / 2
                let centerY = webView.frame.height / 2 - rectHeight / 2
                parent.viewModel.updateClipRect(newRect: (CGRect(x: centerX, y: centerY, width: rectWidth, height: rectHeight)))
            }
        }
        
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                guard let self = self else { return }
                parent.viewModel.updatePageTitle(webView.title)                
                parent.viewModel.saveOriginalSize(newOriginalSize: webView.scrollView.contentSize)
                
                // Initialize clipRect in the center of the WebView frame
                if parent.viewModel.currentClipRect == nil {
                    print("webView ClipRect 2")
                    let rectWidth: CGFloat = 300 // Example width
                    let rectHeight: CGFloat = 300 // Example height
                    let centerX = webView.frame.width / 2 - rectWidth / 2
                    let centerY = webView.frame.height / 2 - rectHeight / 2
                    parent.viewModel.updateClipRect(newRect: (CGRect(x: centerX, y: centerY, width: rectWidth, height: rectHeight)))
                }
            }
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "selectionHandler", let messageBody = message.body as? String {
                let scrollY = parseScrollY(messageBody)
                if scrollY != 0 {
                    parent.captureMenuViewModel.scrollY = scrollY
                }
                
            }
            
            if message.name == "capturedElementsHandler", let messageBody = message.body as? String {
                parseCapturedElements(messageBody)
            }
            
            if message.name == "userStoppedInteracting" {
                // Handle user stop interaction here
                print("userStoppedInteracting", parent.validURL)
                userDidStopInteracting()
            }
            
        }
        
        func userDidStopInteracting() {
            captureScreenshot()
            parent.viewModel.updatePageTitle(webView?.title)
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
            parent.captureMenuViewModel.capturedElements = elements
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
            parent.captureMenuViewModel.scrollY = Double(scrollView.contentOffset.y)
        }
        
        func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            parent.captureMenuViewModel.userInteracting = true
        }
        
        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            if !decelerate {
                parent.captureMenuViewModel.userInteracting = false
            }
        }
        
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            parent.captureMenuViewModel.userInteracting = false
        }
        
        private func captureScreenshot() {
            guard let webView = webView else { return }
            let viewModel = parent.viewModel
            let configuration = WKSnapshotConfiguration()
            if let clipRect = parent.viewModel.currentClipRect {
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
                    viewModel.saveScreenShot(image)
                } else if let error = error {
                    print("Screenshot error: \(error.localizedDescription)")
                }
            }
            
        }
    }
}
