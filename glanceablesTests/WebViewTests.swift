import XCTest

class WebViewUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testWebViewLoading() {
        let webView = app.webViews.firstMatch // Ensure your WebView is accessible
        
        // Test loading URL
        XCTAssertTrue(webView.exists, "WebView does not exist.")
        
        // Wait for the page to load by checking for an element on the page
        let pageTitle = webView.staticTexts["Your Expected Page Title"].firstMatch
        let exists = NSPredicate(format: "exists == true")
        expectation(for: exists, evaluatedWith: pageTitle, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(pageTitle.label, "Your Expected Page Title", "Page title did not match.")
    }

    func testClipRectAdjustment() {
        let webView = app.webViews.firstMatch
        let startCoordinate = webView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let endCoordinate = startCoordinate.withOffset(CGVector(dx: 150, dy: 150)) // Simulate drag to select a 300x300 area
        
        // Start the drag operation
        startCoordinate.press(forDuration: 0.5, thenDragTo: endCoordinate)

        // Since the end result of this action depends on the JavaScript executing properly,
        // and possibly updating an element with the resulting dimensions,
        // we need to wait for that to be visible
        let expectedLabel = "300x300" // Adjust this based on actual test setup and expectations
        let clipDimensionsLabel = webView.staticTexts[expectedLabel].firstMatch
        let clipExists = NSPredicate(format: "exists == true")
        expectation(for: clipExists, evaluatedWith: clipDimensionsLabel, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        
        XCTAssertEqual(clipDimensionsLabel.label, expectedLabel, "Clip dimensions did not match expected values.")
    }
}
