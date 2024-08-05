import SwiftUI

struct WebClipCreatorView: View {
    @StateObject private var captureMenuViewModel = DraggableWebCaptureViewModel()
    
    var body: some View {
        VStack{
            BlackEditMenuBarView()
            VStack{
                WebPreviewCaptureMenuView(
                    viewModel: WebClipEditorViewModel.shared,
                    captureMenuViewModel: captureMenuViewModel,
                    webPreviewCaptureMenuViewModel: WebPreviewCaptureMenuViewModel()
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
