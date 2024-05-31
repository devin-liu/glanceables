import SwiftUI
import WebKit

struct WebBrowserView: View {
    @State private var urlString: String
    @State private var url: URL
    
    init(url: URL) {
        self._url = State(initialValue: url)
        self._urlString = State(initialValue: url.absoluteString)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            WebView(url: $url)
                .frame(maxHeight: .infinity)

            
            TextField("Enter URL", text: $urlString, onCommit: {
                if let newURL = URL(string: urlString) {
                    url = newURL
                }
            })
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
            .background(Color.white.opacity(0.8))
        }                           .cornerRadius(16.0).padding(10)

    }
}
