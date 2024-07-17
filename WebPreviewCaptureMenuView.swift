import SwiftUI
import Combine

struct WebPreviewCaptureMenuView: View {
    @ObservedObject var viewModel: WebClipEditorViewModel
    @ObservedObject var captureMenuViewModel: WebPreviewCaptureMenuViewModel
    
    var body: some View {
        ZStack {
            VStack{
                AddURLFormView(viewModel: viewModel)
                    .padding(10)
                HStack {
                    if !viewModel.isURLValid && !viewModel.urlString.isEmpty {
                        Text("Invalid URL").foregroundColor(.red)
                    }
                    Button("Save") {
                        viewModel.saveURL(with: viewModel.screenShot)
                    }.frame(width: 80, height: 40)
                    
                }
                
                if let screenshot = $viewModel.screenShot.wrappedValue, captureMenuViewModel.showPreview {
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
                                            updateClipRect(endLocation: value.location, bounds: geometry.size)
                                        }
                                        .onEnded { _ in
                                            captureMenuViewModel.dragging = false
                                            //                                        showPreview = true
                                        }
                                )
                            if captureMenuViewModel.captureModeOn {
                                if let clipRect = viewModel.currentClipRect {
                                    if captureMenuViewModel.dragging {
                                        Rectangle()
                                            .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round, dash: [10, 5]))
                                            .path(in: clipRect)
                                            .background(Color.black.opacity(0.1))
                                    }
                                    Rectangle()
                                        .stroke(style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round, dash: [10, 5]))
                                        .path(in: clipRect)
                                }
                            }
                        }
                    }
                }
                Spacer()
            }
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
            // Red 'X' Button Positioned Absolutely at the Top-Right
            VStack {
                HStack {
                    Spacer() // Push everything to the right
                    RedXButton(action: viewModel.resetModalState)
                        .padding(.top, -20) // Negative top padding to move the button outside
                        .padding(.trailing, -20) // Negative top padding to move the button outside
                }
                Spacer() // Push everything to the top
            }
        }
        
        
    }
    
    private func updateClipRect(endLocation: CGPoint, bounds: CGSize) {
        let width = 300.0
        let height = 300.0
        
        let centerX = endLocation.x
        let centerY = endLocation.y
        
        let minX = max(0, min(centerX - width / 2, bounds.width - width))
        let minY = max(0, min(centerY - height / 2, bounds.height - height))
        
        viewModel.currentClipRect = CGRect(x: minX, y: minY, width: width, height: height)
    }
}

struct WebPreviewCaptureMenuView_Previews: PreviewProvider {
    static var previewViewModel: WebClipEditorViewModel = {
        let model = WebClipEditorViewModel()
        model.urlString = "https://news.ycombinator.com/"  // Set the URL string here
        model.validateURL()
        return model
    }()
    static var previews: some View {
        WebPreviewCaptureMenuView(
            viewModel: previewViewModel,
            captureMenuViewModel: WebPreviewCaptureMenuViewModel()
        )
    }
}

