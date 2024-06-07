import SwiftUI

struct WebViewItem: Identifiable, Equatable {
    let id: UUID
    var url: URL    
    var clipRect: CGRect?

    static func ==(lhs: WebViewItem, rhs: WebViewItem) -> Bool {
        return lhs.id == rhs.id && lhs.url == rhs.url
    }
}
