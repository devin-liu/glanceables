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
}
