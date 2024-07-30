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
            function restoreElement() {
                try {
                    const elementSelector = "\(elementSelector)";
                    const element = document.querySelector(elementSelector);
                    const selectors =
                        [{selector: elementSelector, innerText: element.innerText, outerHTML: element.outerHTML}]
                    window.webkit.messageHandlers.elementsFromSelectorsHandler.postMessage(JSON.stringify(selectors));
                } catch (error) {
                    console.error('Error in script:', error);
                    window.webkit.messageHandlers.elementsFromSelectorsHandler.postMessage('Error: ' + error.message);
                }
            }
        
            function watchForElement() {
                const elementSelector = "\(elementSelector)";
                const observer = new MutationObserver((mutationsList, observer) => {
                    const element = document.querySelector(elementSelector);
                    if (element) {
                        restoreElement();
                        observer.disconnect(); // Stop observing once elements are found
                    }
                });
        
                observer.observe(document.body, { childList: true, subtree: true });
        
                // Check if the elements are already present
                const element = document.querySelector(elementSelector);
                if (element) {
                    restoreElements();
                    observer.disconnect();
                }
            }
        
            watchForElement();
        })();
        """
        
        webView.configuration.userContentController.addUserScript(WKUserScript(source: jsCode, injectionTime: .atDocumentEnd, forMainFrameOnly: false))
    }
    
    static func injectIsolateElementFromSelectorScript(webView: WKWebView, elementSelector: String) {
        let jsCode = """
            (function() {
                function watchForElement() {
                    const elementSelector = "\(elementSelector)";
                    const observer = new MutationObserver((mutationsList, observer) => {
                        const element = document.querySelector(elementSelector);
                        if (element) {
                            isolateElement("\(elementSelector)");
                            observer.disconnect(); // Stop observing once elements are found
                        }
                    });
            
                    observer.observe(document.body, { childList: true, subtree: true });
            
                    // Check if the elements are already present
                    const element = document.querySelector(elementSelector);
                    if (element) {
                        isolateElement("\(elementSelector)");
                        observer.disconnect();
                    }
                }
            
                watchForElement();
            })();
            """
        
        webView.configuration.userContentController.addUserScript(WKUserScript(source: jsCode, injectionTime: .atDocumentEnd, forMainFrameOnly: false))
    }
}
