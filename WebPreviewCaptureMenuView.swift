import SwiftUI
import Combine

struct WebPreviewCaptureMenuView: View {
    @ObservedObject var viewModel: WebClipEditorViewModel
    @ObservedObject var captureMenuViewModel: WebPreviewCaptureMenuViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            NavigationView {
                HStack {
                    AddURLFormView(viewModel: viewModel)
                }
                .navigationBarTitle(viewModel.isEditing ? "Edit URL" : "New URL")
                .navigationBarItems(
                    trailing: HStack {
                        CaptureModeToggleView(captureModeOn: $captureMenuViewModel.captureModeOn)
                        RedXButton(action: viewModel.resetModalState)
                    }
                )
            }
            .frame(height: 300)
            .fixedSize(horizontal: false, vertical: true)            
            
            HStack {
                if !viewModel.isURLValid && !viewModel.urlString.isEmpty {
                    Text("Invalid URL").foregroundColor(.red)
                }
                Button("Save") {
                    viewModel.saveURL(with: viewModel.screenShot)
                }.frame(width: 80, height: 40)
                
            }.frame(height: 80).fixedSize(horizontal: false, vertical: true)
            
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
