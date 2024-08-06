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
    var llamaResult: LlamaResult?
    @Published var snapshots: [SnapshotTimelineModel] = []
    
    init(id: UUID, url: URL, clipRect: CGRect? = nil, originalSize: CGSize? = nil, screenshotPath: String? = nil, screenshot: UIImage? = nil, scrollY: Double? = nil, pageTitle: String? = nil, capturedElements: [CapturedElement]? = nil, htmlElements: [HTMLElement]? = nil, llamaResult: LlamaResult? = nil, snapshots: [SnapshotTimelineModel]? = nil) {
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
        self.llamaResult = llamaResult
        self.snapshots = snapshots ?? []
    }
    
    static func ==(lhs: WebClip, rhs: WebClip) -> Bool {
        return lhs.id == rhs.id && lhs.url == rhs.url
    }
    
    func addSnapshotIfNeeded(newSnapshot: UIImage, innerText: String, newLlamaResult: LlamaResult? = nil) {
        print("addSnapshotIfNeeded ", innerText, newLlamaResult)
        // Always save the first snapshot
        
        let conciseText = newLlamaResult?.conciseText
        
        if let screenshotPath = screenshotPath {
            if snapshots.isEmpty {
                appendSnapshot(screenshotPath: screenshotPath, innerText: innerText, conciseText: conciseText)
                return
            }
            
            // Add snapshot if innerText is changed
            if let lastSnapshot = snapshots.last, lastSnapshot.innerText != innerText {
                appendSnapshot(screenshotPath: screenshotPath, innerText: innerText, conciseText: conciseText)
            }
        }
    }
    
    private func appendSnapshot(screenshotPath: String, innerText: String, conciseText: String?) {
        let newSnapshotModel = SnapshotTimelineModel(timestamp: Date(), innerText: innerText, snapshotImagePath: screenshotPath, conciseText: conciseText)
        snapshots.append(newSnapshotModel)
        
        // Send notification
        if let title = pageTitle {
            NotificationManager.shared.sendNotification(title: title, body: innerText)
        }
    }
}
