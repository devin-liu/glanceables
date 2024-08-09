import Foundation
import SwiftUI
import Combine

class WebClipCreatorViewModel: ObservableObject {
    @Published var urlString = ""
    private var urlStringCancellable: AnyCancellable? // To hold the subscription
    private var cancellables: Set<AnyCancellable> = []

    @Published var validURLs: [URL] = []  // Now storing an array of URLs
    @Published var selectedValidURLIndex: Int? = nil {
        didSet {
            print("selectedValidURLIndex", validURLs)
            if let index = selectedValidURLIndex, validURLs.indices.contains(index) {
                urlString = validURLs[index].absoluteString
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
    
    init() {
        $urlString
            .removeDuplicates()
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .sink { [weak self] urlString in
                self?.validateURL(urlString: urlString)
            }
            .store(in: &cancellables)
    }

    var validURL: URL? {
        guard let index = selectedValidURLIndex, validURLs.indices.contains(index) else {
            return nil
        }
        return validURLs[index]
    }
    
    func clearTextField() {
        print("clearTextField")
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
    
    private func validateURL(urlString: String) {
        print("validateURL ", urlString)
//          // Implement URL validation logic here, update isURLValid accordingly
//          isURLValid = URL(string: urlString) != nil
//          showValidationError = !isURLValid && !urlString.isEmpty
//        
                let (isValid, url) = URLUtilities.validateURL(from: urlString)
                print("run validateURL ", urlString, url)
                isURLValid = isValid
        if isValid, let url = url {
            validURLs.append(url)
            selectedValidURLIndex = 0
        }
//                if let url = url {
//                    if validURLs.isEmpty {
//                        validURLs.append(url)
//                        selectedValidURLIndex = 0 // Initialize the index with the first URL
//                    } else {
//                        updateOrAddValidURL(url)
//                    }
//                }
      }
    
//    func validateURL() {
//        let (isValid, url) = URLUtilities.validateURL(from: urlString)
//        print("run validateURL ", urlString, url)
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
//    
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



class Debouncer {
    var workItem: DispatchWorkItem?
    private var interval: TimeInterval

    init(seconds: TimeInterval) {
        self.interval = seconds
    }

    func debounce(action: @escaping () -> Void) {
        workItem?.cancel()
        workItem = DispatchWorkItem(block: action)
        DispatchQueue.main.asyncAfter(deadline: .now() + interval, execute: workItem!)
    }
}
