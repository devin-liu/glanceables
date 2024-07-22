import WebKit

struct JavaScriptLoader {
    static func loadJavaScript(webView: WKWebView, resourceName: String, extensionType: String) {
        guard let scriptURL = Bundle.main.url(forResource: resourceName, withExtension: extensionType),
              let scriptContent = try? String(contentsOf: scriptURL) else {
            print("Failed to load JavaScript file: \(resourceName).\(extensionType)")
            return
        }
        
        let userScript = WKUserScript(source: scriptContent, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        webView.configuration.userContentController.addUserScript(userScript)
    }
    
    static func injectGetElementsFromSelectorsScript(webView: WKWebView, elementSelector: String) {
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
}
