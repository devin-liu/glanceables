import Foundation
import SwiftUI
import Combine

class WebClipCreatorViewModel: ObservableObject {
    @Published var urlString = ""
    @Published var validURLs: [URL] = []  // Now storing an array of URLs    
    @Published var selectedValidURLIndex: Int? = nil {
        didSet {
            if let index = selectedValidURLIndex, validURLs.indices.contains(index) {
                urlString = validURLs[index].absoluteString
            } else {
                urlString = ""  // Clear urlString if there's no valid URL selected
            }
        }
    }
    @Published var currentClipRect: CGRect?
    @Published var isURLValid = true
    @Published var showValidationError = false
    @Published var originalSize: CGSize?
    @Published var pageTitle: String?
    @Published var screenShot: UIImage?
    @Published var screenshotPath: String?
    @Published var capturedElements: [CapturedElement]?
    @Published var snapshots: [SnapshotTimelineModel] = []
    
    private var webClip: PendingWebClip = PendingWebClip()
    private var repository = WebClipUserDefaultsRepository.shared
    
    
    var validURL: URL? {
        guard let index = selectedValidURLIndex, validURLs.indices.contains(index) else {
            return nil
        }
        return validURLs[index]
    }
    
    func clearTextField() {
        urlString = ""
    }
    
    func getNewClip() -> WebClip{
        return WebClip(
            id: UUID(),
            url: validURL!,
            clipRect: currentClipRect,
            originalSize: originalSize,
            screenshotPath: screenShot.flatMap(ScreenshotUtils.saveScreenshotToLocalDirectory) ?? "",
            pageTitle: pageTitle,
            capturedElements: capturedElements,
            snapshots:snapshots
        )
    }
    
    func saveSnapshots(newSnapshots: [SnapshotTimelineModel]){
        snapshots = newSnapshots
    }
    
    func saveCapturedElements(newElements: [CapturedElement]){
        capturedElements = newElements
    }
    
    
    func saveScreenShot(_ newScreenShot: UIImage, toClip:WebClip?=nil) -> String? {
        screenShot = newScreenShot
        if let newScreenshotPath = ScreenshotUtils.saveScreenshotToLocalDirectory(screenshot: newScreenShot) {
            screenshotPath = newScreenshotPath
        }
        
        return nil
    }
    
    
    func saveOriginalSize(newOriginalSize: CGSize) {
        originalSize = newOriginalSize
    }
    
    func validateURL() {
        print("validateURL ", urlString)
        let (isValid, url) = URLUtilities.validateURL(from: urlString)
        isURLValid = isValid
        if let url = url {
            if validURLs.isEmpty {
                validURLs.append(url)
                selectedValidURLIndex = 0 // Initialize the index with the first URL
            } else {
                updateOrAddValidURL(url)
            }
        }
    }
    
    func updateOrAddValidURL(_ newURL: URL) {
        if let selectedIndex = selectedValidURLIndex,
           let currentURL = validURL,
           let newDomain = URLUtilities.extractDomain(from: newURL.absoluteString),
           let currentDomain = URLUtilities.extractDomain(from: currentURL.absoluteString),
           newDomain == currentDomain {
            validURLs[selectedIndex] = newURL // Replace the URL at the current index if domains match
        } else {
            // There is no selected index or domains are not provided; skip domain checking
            print("No selected index or domain provided; adding URL")
            validURLs.append(newURL)
            selectedValidURLIndex = validURLs.count - 1 // Update the index to the new URL if not set
        }
    }
}
