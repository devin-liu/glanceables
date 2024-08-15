import SwiftUI
import WebKit
import Combine

class WebViewCoordinator: NSObject, WKNavigationDelegate, WKUIDelegate, UIScrollViewDelegate, WKScriptMessageHandler {
    var parent: WebViewSnapshotRefresher
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
        print("WebViewcoordinator deinit")
        //        schedulerViewModel.stopScheduler()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        //        let simplifiedPageTitle = URLUtilities.simplifyPageTitle(webView.title ?? "No Title")
        parent.handleDidFinishNavigation(webView: webView)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) { [weak self] in
            guard let self = self else { return }
            parent.handleDidFinishNavigation(webView: webView)
        }
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
