import SwiftUI

struct WebViewItem: Identifiable, Equatable {
    let id: UUID
    var url: URL
    var clipRect: CGRect?
    var originalSize: CGSize?  // Add original size property

    static func ==(lhs: WebViewItem, rhs: WebViewItem) -> Bool {
        return lhs.id == rhs.id && lhs.url == rhs.url
    }
}
