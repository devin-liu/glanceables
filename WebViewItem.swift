import SwiftUI

struct WebViewItem: Identifiable, Equatable {
    let id: UUID
    var url: URL
    var clipRect: CGRect?
    var originalSize: CGSize?
    var screenshotPath: String?  // Add screenshot path property
    var scrollY: Double?

    static func ==(lhs: WebViewItem, rhs: WebViewItem) -> Bool {
        return lhs.id == rhs.id && lhs.url == rhs.url
    }
}
