import Foundation
import SwiftUI
import Combine

@Observable class WebClipManagerViewModel {
    static let shared = WebClipManagerViewModel()  // Singleton instance
    var webClips: [WebClip] = [] {
        didSet {
            print("updated webClips")
        }
    }
//    @Published var urlString = ""
//    @Published var validURLs: [URL] = []  // Now storing an array of URLs
    var isEditing = false
//    @Published var selectedValidURLIndex: Int? = nil {
//        didSet {
//            if let index = selectedValidURLIndex, validURLs.indices.contains(index) {
//                urlString = validURLs[index].absoluteString
//            } else {
//                urlString = ""  // Clear urlString if there's no valid URL selected
//            }
//        }
//    }
    var selectedWebClipIndex: Int? = nil
//    @Published var currentClipRect: CGRect?
//    @Published var isURLValid = true
//    @Published var showValidationError = false
//    @Published var originalSize: CGSize?
//    @Published var pageTitle: String?
//    @Published var screenShot: UIImage?
//    @Published var screenshotPath: String?
    
    private var repository = WebClipUserDefaultsRepository.shared
    
//    var validURL: URL? {
//        guard let index = selectedValidURLIndex, validURLs.indices.contains(index) else {
//            return nil
//        }
//        return validURLs[index]
//    }
//    
//    func clearTextField() {
//        urlString = ""
//    }
    
    // Add a computed property to access a specific WebClip by ID
    func webClip(withId id: UUID) -> WebClip? {
        return webClips.first(where: { $0.id == id })
    }
    
    func selectedWebClip() -> WebClip? {
        guard let index = selectedWebClipIndex, webClips.indices.contains(index) else {
            return nil
        }
        return webClips[index]
    }
    
    func imageForWebClip(withId id: UUID) -> UIImage? {
        guard let webClip = webClip(withId: id) else { return nil }
        return ScreenshotUtils.loadImage(from: webClip.screenshotPath)
    }
    
    
    init() {
        loadWebClips()
    }
    
    func updateScreenshot(_ newScreenShot: UIImage, toClip:WebClip) -> String? {
//        screenShot = newScreenShot
//        if isEditing, let selectedClip = selectedWebClip() {
//            if let newScreenshotPath = ScreenshotUtils.saveScreenshotToFile(using: selectedClip, from: newScreenShot) {
//                updateWebClip(withId: selectedClip.id, newScreenshotPath: newScreenshotPath)
//                return newScreenshotPath
//            }
//        }
//        if let toClip = toClip {        
        print("updateScreenshot ", toClip.screenshotPath)
            if let newScreenshotPath = ScreenshotUtils.saveScreenshotToFile(using: toClip, from: newScreenShot) {
                updateWebClip(withId: toClip.id, newScreenshotPath: newScreenshotPath)
                return newScreenshotPath
            }
//        }
        return nil
    }
//    
//    
//    func saveOriginalSize(newOriginalSize: CGSize) {
//        originalSize = newOriginalSize
//    }
    
    func loadWebClips() {
        webClips = repository.loadWebClips()
    }
    
    func saveWebClips() {
        repository.saveWebClips(webClips)
    }
    
//    func validateURL() {
//        let (isValid, url) = URLUtilities.validateURL(from: urlString)
//        isURLValid = isValid
//        if let url = url {
//            if validURLs.isEmpty {
//                validURLs.append(url)
//                selectedValidURLIndex = 0 // Initialize the index with the first URL
//            } else {
//                updateOrAddValidURL(url)
//            }
//        }
//    }
    
//    func updateOrAddValidURL(_ newURL: URL) {
//        print("updateOrAddValidURL ", newURL)
//        if let selectedIndex = selectedValidURLIndex,
//           let currentURL = validURL,
//           let newDomain = URLUtilities.extractDomain(from: newURL.absoluteString),
//           let currentDomain = URLUtilities.extractDomain(from: currentURL.absoluteString),
//           newDomain == currentDomain {
//            validURLs[selectedIndex] = newURL // Replace the URL at the current index if domains match
//        } else {
//            // There is no selected index or domains are not provided; skip domain checking
//            print("No selected index or domain provided; adding URL")
//            validURLs.append(newURL)
//            selectedValidURLIndex = validURLs.count - 1 // Update the index to the new URL if not set
//        }
//    }
//    
    func createWebClip(newClip: WebClip){
        webClips.append(newClip)
        saveWebClips()
        loadWebClips()
    }
    
//    func addWebClip(screenshot: UIImage?, capturedElements: [CapturedElement]?, snapshots: [SnapshotTimelineModel]?) {
//        guard isURLValid, validURL != nil else { return }
//        let newWebClip = WebClip(
//            id: UUID(),
//            url: validURL!,
//            clipRect: currentClipRect,
//            originalSize: originalSize,
//            screenshotPath: screenshot.flatMap(ScreenshotUtils.saveScreenshotToLocalDirectory) ?? "",
//            pageTitle: pageTitle,
//            capturedElements: capturedElements,
//            snapshots:snapshots
//        )
//        webClips.append(newWebClip)
//        saveWebClips()
//    }
    
    func updateWebClip(withId id: UUID, newURL: URL? = nil, newClipRect: CGRect? = nil, newScreenshotPath: String? = nil, newPageTitle: String? = nil, newCapturedElements: [CapturedElement]? = nil, newLlamaResult: LlamaResult? = nil, newInnerText: String? = nil) {
        guard let index = webClips.firstIndex(where: { $0.id == id }) else {
            return
        }
        let updatedWebClip = webClips[index]
        
        if let newURL = newURL {
            updatedWebClip.url = newURL
        }
        if let newClipRect = newClipRect {
            updatedWebClip.clipRect = newClipRect
        }
        if let newScreenshotPath = newScreenshotPath {
            updatedWebClip.screenshotPath = newScreenshotPath
        }
        if let newPageTitle = newPageTitle {
            updatedWebClip.pageTitle = newPageTitle
        }
        if let newCapturedElements = newCapturedElements {
            updatedWebClip.capturedElements = newCapturedElements
        }
        
        repository.updateWebClip(updatedWebClip)
        loadWebClips()
    }
    
    func openEditForItem(_ item: WebClip) {
        guard let index = webClips.firstIndex(where: { $0.id == item.id }) else { return }
        selectedWebClipIndex = index
//        urlString = webClips[index].url.absoluteString
//        isEditing = true
    }
    
    
    func deleteItem(item: WebClip) {
        repository.deleteWebClip(item)
        loadWebClips()
    }
    
    func moveItem(fromOffsets: IndexSet, toOffset: Int) {
        webClips.move(fromOffsets: fromOffsets, toOffset: toOffset)
        saveWebClips() // Persist the new order in the repository
    }
    
    func reset() {
//        urlString = ""
//        validURLs.removeAll()
//        selectedValidURLIndex = nil
        selectedWebClipIndex = nil
//        currentClipRect = nil
//        isURLValid = true
//        showValidationError = false
//        originalSize = nil
//        pageTitle = nil
//        screenShot = nil
//        screenshotPath = nil
    }
}
