import SwiftUI

struct WebClipCreatorView: View {
    @StateObject private var captureMenuViewModel = WebClipSelectorViewModel.shared
    
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
    }
}

struct WebClipCreatorView_Previews: PreviewProvider {
    static var previews: some View {
        WebClipCreatorView()
    }
}
