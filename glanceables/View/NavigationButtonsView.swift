import SwiftUI
import WebKit

struct NavigationButtonsView: View {
    var webView: WKWebView
    
    var body: some View {
        HStack {
            Button(action: {
                webView.goBack()
            }) {
                Image(systemName: "chevron.left")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(!webView.canGoBack)

            Button(action: {
                webView.goForward()
            }) {
                Image(systemName: "chevron.right")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(!webView.canGoForward)
        }
    }
}
