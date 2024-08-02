import SwiftUI

struct WebClip: Identifiable, Equatable {
    let id: UUID
    var url: URL
    var clipRect: CGRect?
    var originalSize: CGSize?
    var screenshotPath: String?  // Add screenshot path property
    var screenshot: UIImage?
    var scrollY: Double?
    var pageTitle: String?
    var capturedElements: [CapturedElement]?
    var htmlElements: [HTMLElement]?
    var llamaResult: LlamaResult?  // Add a property for LlamaResult
    var snapshots: [SnapshotTimelineModel]?


    static func ==(lhs: WebClip, rhs: WebClip) -> Bool {
        return lhs.id == rhs.id && lhs.url == rhs.url
    }
}
