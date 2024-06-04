import SwiftUI
import WebKit

struct WebBrowserView: View {
    @State private var urlString: String
    @State private var url: URL
    @State private var pageTitle: String = "Loading..."

    init(url: URL) {
        self._url = State(initialValue: url)
        self._urlString = State(initialValue: url.absoluteString)
    }
    
    var body: some View {
        VStack {
            ZStack(alignment: .top) {
                WebView(url: $url, pageTitle: $pageTitle)
                    .frame(maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
            }
            .cornerRadius(16.0)
            .padding(10)
            
            Text(pageTitle)
                .font(.headline)
                .padding()
        }
    }
}

struct WebBrowserView_Previews: PreviewProvider {
    static var previews: some View {
        WebBrowserView(url: URL(string: "https://www.apple.com")!)
    }
}
