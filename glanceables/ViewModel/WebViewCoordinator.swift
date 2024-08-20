import SwiftUI
import WebKit
import Combine

class WebViewCoordinator: NSObject, WKNavigationDelegate, WKUIDelegate, UIScrollViewDelegate, WKScriptMessageHandler {
    var parent: WebViewSnapshotRefresher?
    var webView: WKWebView?
    //    var reloadSubscription: AnyCancellable?
    //    var webClipId: UUID
    //    var llamaAPIManager: LlamaAPIManager
    
    private var cancellables = Set<AnyCancellable>()
    
    init(_ parent: WebViewSnapshotRefresher) {
        self.parent = parent
        //        self.webClipId = webClipId
        //        self.llamaAPIManager = llamaAPIManager
        super.init()
    }
    
    deinit {
        //        TODO make this get hit as well
        print("Snapshot WebViewcoordinator deinitialized")
        //        schedulerViewModel.stopScheduler()
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
