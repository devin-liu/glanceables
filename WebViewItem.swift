import SwiftUI

struct WebClip: Identifiable, Equatable {
    let id: UUID
    var url: URL
    var clipRect: CGRect?
    var originalSize: CGSize?
    var screenshotPath: String?  // Add screenshot path property
    var scrollY: Double?
    var capturedElements: [CapturedElement]?

    static func ==(lhs: WebClip, rhs: WebClip) -> Bool {
        return lhs.id == rhs.id && lhs.url == rhs.url
    }
}
