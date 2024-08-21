import SwiftUI

class WebClip: ObservableObject, Identifiable, Equatable {
    let id: UUID
    @Published var url: URL
    var clipRect: CGRect?
    var originalSize: CGSize?
    @Published var screenshotPath: String?  // Observable property
    @Published var screenshot: UIImage?  // Observable property
    var scrollY: Double?
    @Published var pageTitle: String?
    var capturedElements: [CapturedElement]?
    var htmlElements: [HTMLElement]?
    @Published var snapshots: [SnapshotTimelineModel] = []
    //    private var pendingUpdates: [SnapshotUpdate] = [] {
    //        didSet {
    //            print("pendingUpdates \(id) \(pendingUpdates.count)", pendingUpdates)
    //        }
    //    }
    
    init(id: UUID, url: URL, clipRect: CGRect? = nil, originalSize: CGSize? = nil, screenshotPath: String? = nil, screenshot: UIImage? = nil, scrollY: Double? = nil, pageTitle: String? = nil, capturedElements: [CapturedElement]? = nil, htmlElements: [HTMLElement]? = nil, snapshots: [SnapshotTimelineModel]? = nil) {
        self.id = id
        self.url = url
        self.clipRect = clipRect
        self.originalSize = originalSize
        self._screenshotPath = Published(initialValue: screenshotPath)
        self._screenshot = Published(initialValue: screenshot)
        self.scrollY = scrollY
        self.pageTitle = pageTitle
        self.capturedElements = capturedElements
        self.htmlElements = htmlElements
        self.snapshots = snapshots ?? []
    }
    
    static func ==(lhs: WebClip, rhs: WebClip) -> Bool {
        return lhs.id == rhs.id && lhs.url == rhs.url
    }
    
    func addSnapshotIfNeeded(screenshotPath: String, innerText: String, conciseText: String? = nil) {
        if snapshots.isEmpty {
            appendSnapshot(screenshotPath: screenshotPath, innerText: innerText, conciseText: conciseText)
            return
        }
        
        // Add snapshot if innerText is changed
        if let lastSnapshot = snapshots.last, lastSnapshot.innerText != innerText {
            appendSnapshot(screenshotPath: screenshotPath, innerText: innerText, conciseText: conciseText)
        }
    }
    
    private func appendSnapshot(screenshotPath: String, innerText: String, conciseText: String?) {
        let newSnapshotModel = SnapshotTimelineModel(timestamp: Date(), innerText: innerText, snapshotImagePath: screenshotPath, conciseText: conciseText)
        snapshots.append(newSnapshotModel)
        
        persistSnapshots()
        
        // Check if the appended snapshot is not the first one and then send a notification
        if snapshots.count > 1, let title = pageTitle {
            NotificationManager.sendNotification(title: title, body: innerText)
        }
    }
    
    func reset() {
        // Reset URL and path-related properties
        url = URL(string: "about:blank")!  // Assigning a default blank URL
        clipRect = nil
        originalSize = nil
        screenshotPath = nil
        screenshot = nil
        scrollY = nil
        pageTitle = nil
        
        // Clear collections
        capturedElements = []
        htmlElements = []
        snapshots = []                        
    }
}


extension WebClip {
    func persistSnapshots() {
        WebClipUserDefaultsRepository.updateWebClip(self)
    }
}

struct PendingWebClip {
    var id: UUID = UUID()
    var url: URL?  // Changed to optional
    var clipRect: CGRect?
    var originalSize: CGSize?
    var screenshotPath: String?
    var scrollY: Double?
    var pageTitle: String?
    var capturedElements: [CapturedElement]?  // Assumed to be defined elsewhere
    var htmlElements: [HTMLElement]?  // Assumed to be defined elsewhere
}


extension WebClip: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(url)
    }
    
    func toPendingWebClip() -> PendingWebClip {
        var pendingClip = PendingWebClip()
        pendingClip.id = self.id  // Retain the same UUID for continuity
        pendingClip.url = self.url
        pendingClip.clipRect = self.clipRect
        pendingClip.originalSize = self.originalSize
        pendingClip.screenshotPath = self.screenshotPath
        pendingClip.scrollY = self.scrollY
        pendingClip.pageTitle = self.pageTitle
        pendingClip.capturedElements = self.capturedElements
        pendingClip.htmlElements = self.htmlElements
        
        return pendingClip
    }
}
