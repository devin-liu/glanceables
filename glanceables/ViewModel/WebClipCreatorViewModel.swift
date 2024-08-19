import Foundation
import SwiftUI
import Combine

class WebClipCreatorViewModel: ObservableObject {
    @Published var urlString = "" {
        didSet {
            debouncer.debounce {
                self.validateURL(self.urlString)
            }
        }
    }    
    
    private var debouncer: Debouncer = Debouncer(seconds: 0.3)
    private var urlStringCancellable: AnyCancellable? // To hold the subscription
    private var cancellables: Set<AnyCancellable> = []
    
    @Published var validURLs: [URL] = []
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
    
    init() {}
    
    var validURL: URL? {
        return validURLs.last
    }
    
    func clearTextField() {
        print("clearTextField")
        urlString = ""
    }
    
    func updateClipRect(newRect: CGRect){
        currentClipRect = newRect
    }
    
    func updatePageTitle(_ newTitle: String?){
        let simpleTitle = URLUtilities.simplifyPageTitle(newTitle ?? "No Title")
        pageTitle = simpleTitle
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
    
    private func validateURL(_ urlString: String) {
        debouncer.cancel()
        let (isValid, url) = URLUtilities.validateURL(from: urlString)
        isURLValid = isValid
        if isValid, let url = url {
            validURLs.append(url)
        }
        
    }
}

class Debouncer {
    private var workItem: DispatchWorkItem?
    private let interval: TimeInterval
    
    init(seconds: TimeInterval) {
        self.interval = seconds
    }
    
    func debounce(action: @escaping () -> Void) {
        workItem?.cancel()
        workItem = DispatchWorkItem(block: action)
        DispatchQueue.main.asyncAfter(deadline: .now() + interval, execute: workItem!)
    }
    
    // Ensure this method is properly defined
    func cancel() {
        workItem?.cancel()
        workItem = nil
    }
}
