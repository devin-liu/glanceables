import XCTest

// Create a testable instance of the view model to manage the view logic
class URLModalViewTests: XCTestCase {

    // Setup your test environment variables
    var showingURLModal: Bool = false
    var urlString: String = ""
    var isURLValid: Bool = false
    var urls: [WebViewItem] = []
    var selectedURLIndex: Int? = nil
    var isEditing: Bool = false
    var validURL: URL? = nil

    override func setUp() {
        super.setUp()
        // Reset the environment before each test
        showingURLModal = false
        urlString = ""
        isURLValid = false
        urls = []
        selectedURLIndex = nil
        isEditing = false
        validURL = nil
    }

    func testValidURL() {
        urlString = "https://www.example.com"
        validateURL()
        XCTAssertTrue(isURLValid)
        XCTAssertNotNil(validURL)
    }

    func testInvalidURL() {
        urlString = "htt:/example"
        validateURL()
        XCTAssertFalse(isURLValid)
        XCTAssertNil(validURL)
    }

    func testHandleSaveURL_ValidData() {
        urlString = "https://www.example.com"
        validateURL()
        handleSaveURL()
        XCTAssertFalse(showingURLModal) // Modal should be closed
        XCTAssertEqual(urls.count, 1) // New URL should be added
    }

    func testResetModalState() {
        resetModalState()
        XCTAssertFalse(showingURLModal)
        XCTAssertTrue(urlString.isEmpty)
        XCTAssertTrue(isURLValid)
        XCTAssertNil(selectedURLIndex)
        XCTAssertNil(validURL)
    }

    // Implementation of actual methods under test
    private func validateURL() {
        if !urlString.hasPrefix("http://") && !urlString.hasPrefix("https://") {
            urlString = "https://" + urlString
        }
        if let url = URL(string: urlString), canOpenURL(urlString) && isValidURLFormat(urlString) {
            isURLValid = true
            validURL = url
        } else {
            isURLValid = false
            validURL = nil
        }
    }

    private func canOpenURL(_ string: String?) -> Bool {
        guard let urlString = string, let url = URL(string: urlString) else {
            return false
        }
        return UIApplication.shared.canOpenURL(url)
    }

    private func isValidURLFormat(_ string: String) -> Bool {
        let regex = "^(https?://)?([\\w\\d-]+\\.)+[\\w\\d-]+/?([\\w\\d-._\\?,'+/&%$#=~]*)*[^.]$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: string)
    }

    private func handleSaveURL() {
        if isURLValid && !urlString.isEmpty {
            let newUrlItem = WebViewItem(id: UUID(), url: URL(string: urlString)!, clipRect: nil)
            if isEditing, let index = selectedURLIndex {
                urls[index] = newUrlItem
            } else {
                urls.append(newUrlItem)
            }
            resetModalState() // Reset modal only on successful save
        }
    }

    private func resetModalState() {
        showingURLModal = false
        urlString = ""
        isEditing = false
        selectedURLIndex = nil
        isURLValid = true // Reset to true so the error message won't persist across different uses of the modal
        validURL = nil
    }
}
