import SwiftUI

struct CaptureRectangleView: View {
    @ObservedObject var captureMenuViewModel: WebPreviewCaptureMenuViewModel
    @ObservedObject var viewModel: WebClipEditorViewModel
    
    var body: some View {
        ZStack {
            if captureMenuViewModel.dragEnded {
                // Gray overlay
                GeometryReader { geometry in
                    Path { path in
                        // Full screen rectangle
                        path.addRect(CGRect(origin: .zero, size: geometry.size))
                        
                        // Subtract the clip rectangle if it exists
                        if let clipRect = viewModel.currentClipRect {
                            path.addRect(clipRect)
                        }
                    }
                    .fill(Color.gray.opacity(0.5), style: FillStyle(eoFill: true))
                    
                    .edgesIgnoringSafeArea(.all)
                    .allowsHitTesting(false)
                }
            }
            if captureMenuViewModel.captureModeOn {
                captureModeContent                
            }
        }
    }
    
    
    @ViewBuilder
    private var captureModeContent: some View {
        if let clipRect = viewModel.currentClipRect {
            Rectangle()
                .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round, dash: [10, 5]))
                .frame(width: clipRect.width, height: clipRect.height)
                .overlay(saveButtonOverlay, alignment: .topTrailing)
                .position(x: clipRect.midX, y: clipRect.midY)
        }
    }
    
    @ViewBuilder
    private var saveButtonOverlay: some View {
        if captureMenuViewModel.dragEnded {
            SaveButtonView {
                viewModel.saveURL(screenshot: viewModel.screenShot, capturedElements: captureMenuViewModel.capturedElements)
            }
            .offset(x: -10, y: -65)
        } else {
            EmptyView()
        }
    }
}

struct CaptureRectangleView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            let viewModel = WebClipEditorViewModel()
            let captureMenuViewModel = WebPreviewCaptureMenuViewModel()
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            viewModel.currentClipRect = CGRect(
                x: screenWidth / 2 - 150,
                y: 100,
                width: 300,
                height: 300
            )
            captureMenuViewModel.captureModeOn = true
            
            return CaptureRectangleView(
                captureMenuViewModel: captureMenuViewModel,
                viewModel: viewModel
            )
            .frame(width: screenWidth, height: screenHeight)
        }
    }
}


