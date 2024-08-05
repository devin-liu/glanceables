import SwiftUI

struct WebClipCreatorView: View {
    @ObservedObject var contentViewModel: DashboardViewModel
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
        // Create a sample instance of DashboardViewModel if it has a shared instance or initializers
        let sampleDashboardViewModel = DashboardViewModel.shared // Assuming a shared instance is available
        WebClipCreatorView(contentViewModel: sampleDashboardViewModel)
    }
}
