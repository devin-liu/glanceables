import SwiftUI

struct WebClipCreatorView: View {
    @ObservedObject private var captureMenuViewModel = WebClipSelectorViewModel.shared
    @ObservedObject private var creatorViewModel = WebClipCreatorViewModel()
    var body: some View {
        VStack{
            BlackEditMenuBarView()
            VStack{
                WebClipBrowserMenuView(pendingClip: creatorViewModel)
            }.padding(20)
        }
        .background(Color(.systemGray5).opacity(0.25))
        .navigationBarHidden(true)        
        .onDisappear{
            WebClipManagerViewModel.shared.reset()
            print("creator reset")
        }
    }
}

struct WebClipCreatorView_Previews: PreviewProvider {
    static var previews: some View {
        WebClipCreatorView()
    }
}
