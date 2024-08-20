import SwiftUI
import WebKit
import Combine

class WebViewCoordinator: NSObject, WKNavigationDelegate, WKUIDelegate, UIScrollViewDelegate, WKScriptMessageHandler {
    var parent: WebViewSnapshotRefresher?
    var webView: WKWebView?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(_ parent: WebViewSnapshotRefresher) {
        self.parent = parent
        super.init()
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
    
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        parent!.handleDidFinishNavigation(webView: webView)
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let webView = webView else { return }
        if message.name == "elementsFromSelectorsHandler", let messageBody = message.body as? String {
            parseElementsFromSelectors(messageBody)
            parent!.captureScreenshot(webView: webView)
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
                parent!.processElementsInnerText(innerText)
            }
            
        } catch {
            print("Error: \(error)")
        }
    }
}

// An solution to avoid memory leaks
class LeakAvoider : NSObject, WKScriptMessageHandler {
    weak var delegate : WKScriptMessageHandler?
    init(delegate:WKScriptMessageHandler) {
        self.delegate = delegate
        super.init()
    }
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        self.delegate?.userContentController(
            userContentController, didReceive: message)
    }
}
