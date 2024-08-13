import Foundation
import SwiftUI
import Combine

@Observable class WebClipManagerViewModel {
//    static let shared = WebClipManagerViewModel()  // Singleton instance
    var webClips: [WebClip] = [] {
        didSet {
            print("updated webClips", webClips.count)
        }
    }
    
    init() {
        loadWebClips()
    }
    
    public func isEmpty() -> Bool {
        return webClips.count == 0
    }
    
    public func getClips() -> [WebClip] {
        print("getClips")
        return webClips
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

    func loadWebClips() {
        webClips = repository.loadWebClips()
    }
    
    func saveWebClips() {
        repository.saveWebClips(webClips)
    }
    
    func createWebClip(newClip: WebClip){
        webClips.append(newClip)
        saveWebClips()
        loadWebClips()
    }
 
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
    
    func deleteItemById(_ id: UUID) {
        repository.deleteWebClipById(id)
        loadWebClips()
    }
    
    func moveItem(fromOffsets: IndexSet, toOffset: Int) {
        webClips.move(fromOffsets: fromOffsets, toOffset: toOffset)
        saveWebClips() // Persist the new order in the repository
    }
    
    func reset() {
        isEditing = false
        selectedWebClipIndex = nil
    }
}
