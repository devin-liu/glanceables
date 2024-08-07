import SwiftUI

struct WebClipCreatorView: View {
    @ObservedObject private var captureMenuViewModel = WebClipSelectorViewModel.shared
    @StateObject private var creatorViewModel = WebClipCreatorViewModel()
    var body: some View {
        VStack{
            BlackEditMenuBarView()
            VStack{
                WebClipBrowserMenuView(
                    viewModel: WebClipManagerViewModel.shared,
                    captureMenuViewModel: captureMenuViewModel
                )
            }.padding(20)
        }
        .background(Color(.systemGray5).opacity(0.25))
        .navigationBarHidden(true)
        .onDisappear{
            WebClipManagerViewModel.shared.reset()
        }
    }
}

struct WebClipCreatorView_Previews: PreviewProvider {
    static var previews: some View {
        WebClipCreatorView()
    }
}
