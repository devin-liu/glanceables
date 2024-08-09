import SwiftUI

struct WebClipCreatorView: View {
    @StateObject private var creatorViewModel = WebClipCreatorViewModel()
    @ObservedObject private var webClipSelector = WebClipSelectorViewModel()
    var body: some View {
        VStack{
            BlackEditMenuBarView()
            VStack{
                WebClipBrowserMenuView(webClipSelector: webClipSelector, pendingClip: creatorViewModel)
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
        WebClipCreatorView()
    }
}
