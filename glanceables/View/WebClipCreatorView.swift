import SwiftUI

struct WebClipCreatorView: View {
    @StateObject private var creatorViewModel = WebClipCreatorViewModel()
    @StateObject private var webClipSelector = WebClipSelectorViewModel()
    var webClipManager: WebClipManagerViewModel
    var body: some View {
        VStack{
            BlackEditMenuBarView(webClipSelector: webClipSelector)
            VStack{
                WebClipBrowserMenuView(webClipManager: webClipManager, webClipSelector: webClipSelector, pendingClip: creatorViewModel)
            }.padding(20)
        }
        .background(Color(.systemGray5).opacity(0.25))
        .navigationBarHidden(true)        
        .onDisappear{
            print("creator reset")
        }
    }
}

struct WebClipCreatorView_Previews: PreviewProvider {
    static var previews: some View {
        let webClipManager = WebClipManagerViewModel()
        WebClipCreatorView(webClipManager: webClipManager)
    }
}
