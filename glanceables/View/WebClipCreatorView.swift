import SwiftUI

struct WebClipCreatorView: View {
    @Environment(WebClipManagerViewModel.self) private var webClipManager
    @StateObject private var webClipSelector = WebClipSelectorViewModel()

    var body: some View {
        VStack{
            BlackEditMenuBarView(webClipSelector: webClipSelector)
            VStack{
                WebClipBrowserMenuView(webClipSelector: webClipSelector)
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
        WebClipCreatorView()
    }
}
