import SwiftUI
import Combine

struct WebClipBrowserMenuView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: WebClipManagerViewModel
    @ObservedObject var captureMenuViewModel = WebClipSelectorViewModel.shared
    @ObservedObject var dashboardViewModel = DashboardViewModel.shared
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    NavigationButtonsView(viewModel: viewModel)
                        .padding(10)
                    AddURLFormView(viewModel: viewModel) // Create a new instance or pass as needed
                        .padding(10)
                }
                
                if let screenshot = viewModel.screenShot, captureMenuViewModel.showPreview {
                    Image(uiImage: screenshot)
                        .frame(width: 300, height: 300)
                        .padding()
                }
                
                if viewModel.isURLValid && !captureMenuViewModel.showPreview {
                    GeometryReader { geometry in
                        ZStack {
                            WebViewScreenshotCapture(viewModel: viewModel, captureMenuViewModel: captureMenuViewModel)
                                .frame(maxHeight: .infinity)
                                .frame(width: geometry.size.width)
                                .gesture(
                                    DragGesture(minimumDistance: 0)
                                        .onChanged { value in
                                            captureMenuViewModel.startLocation = captureMenuViewModel.startLocation ?? value.location
                                            captureMenuViewModel.endLocation = value.location
                                            captureMenuViewModel.dragging = true
                                            captureMenuViewModel.dragEnded = false
                                            captureMenuViewModel.updateClipRect(endLocation: value.location, bounds: geometry.size)
                                            viewModel.currentClipRect = captureMenuViewModel.currentClipRect
                                        }
                                        .onEnded { _ in
                                            captureMenuViewModel.dragging = false
                                            captureMenuViewModel.dragEnded = true
                                        }
                                )
                            if captureMenuViewModel.captureModeOn {
                                CaptureRectangleView(captureMenuViewModel: captureMenuViewModel, webClipManager: viewModel)
                            }
                        }
                    }
                }
                Spacer()
            }
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
            VStack {
                HStack {
                    Spacer()
                    RedXButton(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    })
                    .padding(.top, -20)
                    .padding(.trailing, -20)
                }
                Spacer()
            }
        }
    }
}

struct WebPreviewCaptureMenuView_Previews: PreviewProvider {
    static var previewViewModel: WebClipManagerViewModel = {
        let model = WebClipManagerViewModel()
        model.urlString = "https://news.ycombinator.com/"
        model.validateURL()
        return model
    }()
    static var previews: some View {
        WebClipBrowserMenuView(
            viewModel: previewViewModel,
            captureMenuViewModel: WebClipSelectorViewModel()            
        )
    }
}
