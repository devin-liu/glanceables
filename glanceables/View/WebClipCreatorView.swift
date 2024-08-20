import SwiftUI

struct WebClipCreatorView: View {
    @Environment(WebClipManagerViewModel.self) private var webClipManager
    @Environment(\.dismiss) private var dismiss
    @StateObject private var webClipSelector = WebClipSelectorViewModel()
    @State var pendingClip = WebClipCreatorViewModel()    
    private var webClip: WebClip?
    
    init(webClip: WebClip? = nil) {
        self.webClip = webClip
        if let webClip {
            pendingClip.updatePendingWebClip(newPendingClip: webClip.toPendingWebClip())
        }
        print("WebClipCreatorView init", webClip)
        //        this does not reset in between hitting dismiss on blank creator views
        
    }
    
    var body: some View {
        VStack{
            BlackEditMenuBarView(webClipSelector: webClipSelector)
            VStack{
                WebClipBrowserMenuView(webClipSelector: webClipSelector, dismiss: dismiss, pendingClip: pendingClip)
            }.padding(20)
        }
        .background(Color(.systemGray5).opacity(0.25))
        .navigationBarHidden(true)
        .onDisappear {
            // Perform any clean up tasks here            
            pendingClip.reset()
            print("WebClipCreatorView is disappearing")
        }
    }
}
