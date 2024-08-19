import SwiftUI

struct WebClipCreatorView: View {
    @Environment(WebClipManagerViewModel.self) private var webClipManager
    @StateObject private var webClipSelector = WebClipSelectorViewModel()
    @StateObject var pendingClip = WebClipCreatorViewModel()
    
    private var webClip: WebClip?
    
    init(webClip: WebClip? = nil) {
        
        self.webClip = webClip
        if let webClip {
            print("WebClipCreatorView  existing webclip ", webClip, webClip.url, webClip.pageTitle)
            pendingClip.updatePendingWebClip(newPendingClip: webClip.toPendingWebClip())
        }
        
    }
    
    var body: some View {
        VStack{
            BlackEditMenuBarView(webClipSelector: webClipSelector)
            VStack{
                WebClipBrowserMenuView(webClipSelector: webClipSelector, pendingClip: pendingClip)
            }.padding(20)
        }
        .background(Color(.systemGray5).opacity(0.25))
        .navigationBarHidden(true)
    }
}
//
//struct WebClipCreatorView_Previews: PreviewProvider {
//    static var previews: some View {
//        let webClipManager = WebClipManagerViewModel()
//        WebClipCreatorView()
//    }
//}
