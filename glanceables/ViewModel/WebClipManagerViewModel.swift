import Foundation
import SwiftUI

@Observable class WebClipManagerViewModel {
    private var webClips: [WebClip] = [] {
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
    
    // Add a computed property to access a specific WebClip by ID
    func webClip(_ id: UUID) -> WebClip? {
        return webClips.first(where: { $0.id == id })
    }
    
    func selectedWebClip() -> WebClip? {
        guard let index = selectedWebClipIndex, webClips.indices.contains(index) else {
            return nil
        }
        return webClips[index]
    }
    
    func imageForWebClip(withId id: UUID) -> UIImage? {
        guard let webClip = webClip(id) else { return nil }
        return ScreenshotUtils.loadImage(from: webClip.screenshotPath)
    }
    
    func updateScreenshot(_ newScreenShot: UIImage, toClipId:UUID) -> String? {
        if let toClip = webClip(toClipId){
            if let screenshotPath = toClip.screenshotPath{
                print("updateScreenshot ", screenshotPath)
                if let newScreenshotPath = ScreenshotUtils.saveScreenshotToFile(screenshotPath: screenshotPath, from: newScreenShot) {
                    updateWebClip(withId: toClip.id, newScreenshotPath: newScreenshotPath)
                    return newScreenshotPath
                }
            }
        }
        return nil
    }
    
    func loadWebClips() {
        webClips = WebClipUserDefaultsRepository.loadWebClips()
    }
    
    func saveWebClips() {
        WebClipUserDefaultsRepository.saveWebClips(webClips)
    }
    
    func createWebClip(newClip: WebClip){
        webClips.append(newClip)
        saveWebClips()
        //        loadWebClips()
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
        
        WebClipUserDefaultsRepository.updateWebClip(updatedWebClip)
        loadWebClips()
    }
    
    func openEditForItem(_ id: UUID) {
        guard let index = webClips.firstIndex(where: { $0.id == id }) else { return }
        selectedWebClipIndex = index
    }
    
    func deleteItemById(_ id: UUID) {
        WebClipUserDefaultsRepository.deleteWebClipById(id)
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
