import SwiftUI

struct WebClipCreatorView: View {
    @Environment(WebClipManagerViewModel.self) private var webClipManager
    @StateObject private var webClipSelector = WebClipSelectorViewModel()
    @State var pendingClip = WebClipCreatorViewModel()    
    private var webClip: WebClip?
    
    init(webClip: WebClip? = nil) {
        self.webClip = webClip
        if let webClip {
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
