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
                if let clipRect = viewModel.currentClipRect {
                    if captureMenuViewModel.dragging {
                        Rectangle()
                            .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round, dash: [10, 5]))
                        
                            .frame(width: clipRect.width, height: clipRect.height)
                            .position(x: clipRect.midX, y: clipRect.midY)
                    }else{
                        Rectangle()
                            .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round, dash: [10, 5]))
                            .frame(width: clipRect.width, height: clipRect.height)
                            .overlay(
                                SaveButtonView {
                                    viewModel.saveURL(with: viewModel.screenShot)
                                }
                                    .offset(x: -10, y: -65)
                                , alignment: .topTrailing
                            )
                            .position(x: clipRect.midX, y: clipRect.midY)
                    }
                }
            }
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
