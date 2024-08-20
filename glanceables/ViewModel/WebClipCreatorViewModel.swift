import Foundation
import SwiftUI
import Combine
import WebKit

@Observable class WebClipCreatorViewModel {
    var urlString = "" {
        didSet {
            debouncer.debounce {
                self.validateURL(self.urlString)
            }
        }
    }
    
    private var debouncer: Debouncer = Debouncer(seconds: 0.3)
    private var urlStringCancellable: AnyCancellable? // To hold the subscription
    private var cancellables: Set<AnyCancellable> = []
    
    var validURLs: [URL] = []
    var currentClipRect: CGRect?
    var isURLValid = true
    var showValidationError = false
    var originalSize: CGSize?
    var pageTitle: String?
    var screenShot: UIImage?
    var screenshotPath: String?
    var capturedElements: [CapturedElement]?
    var snapshots: [SnapshotTimelineModel] = []
    weak var webView: WKWebView?
    
    private var webClip: PendingWebClip = PendingWebClip()
    
    init() {}
    
    var validURL: URL? {
        return validURLs.last
    }
    
    func updateWebView(newWebView: WKWebView){
        webView = newWebView
    }
    
    func updateUrlString(_ newText: String){
        urlString = newText
    }
    
    func updatePendingWebClip(newPendingClip: PendingWebClip){
        webClip = newPendingClip
        updateUrlString(newPendingClip.url!.absoluteString)
    }
    
    func clearTextField() {
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
    
    func finalizeClip(){
        if let webView = webView {
            updatePageTitle(webView.title)
            if let newURL = webView.url {
                validURLs.append(newURL)
            }
            
        }
    }
    
    func reset() {
        // Reset basic string and URL properties
        urlString = ""
        validURLs.removeAll()
        
        // Reset state flags
        isURLValid = true
        showValidationError = false
        
        // Reset geometry and image properties
        currentClipRect = nil
        originalSize = nil
        pageTitle = nil
        screenShot = nil
        screenshotPath = nil
        
        // Reset collections
        capturedElements = []
        snapshots.removeAll()
        
        // Reset web view
        webView = nil
        
        // Clear any held subscriptions if any
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        
        // Reset the internal web clip model
        webClip = PendingWebClip()
        
        // Clear any pending operations in debouncer
        debouncer.cancel()
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
