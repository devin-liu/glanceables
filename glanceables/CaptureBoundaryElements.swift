import JavaScriptCore

class CaptureBoundaryElements {
    var jsContext: JSContext!

    init() {
        setupJavaScriptContext()
    }

    func setupJavaScriptContext() {
        jsContext = JSContext()

        // Error handling
        jsContext.exceptionHandler = { context, exception in
            print("JS Error: \(exception?.toString() ?? "unknown error")")
        }

        // Load the JavaScript code
        if let jsSourcePath = Bundle.main.path(forResource: "captureElements", ofType: "js"),
           let jsSourceContents = try? String(contentsOfFile: jsSourcePath) {
            jsContext.evaluateScript(jsSourceContents)
        }
    }
    
    func getElements(x: Int, y: Int) -> [String] {
        let function = jsContext.objectForKeyedSubscript("getElementsWithinBoundary")
        if let result = function?.call(withArguments: [x, y]) {
            return result.toArray() as? [String] ?? []
        }
        return []
    }

    func findElements(usingSelectors selectors: [String]) -> [String] {
        let function = jsContext.objectForKeyedSubscript("getElementsFromSelectors")
        if let result = function?.call(withArguments: [selectors]) {
            return result.toArray() as? [String] ?? []
        }
        return []
    }

}
