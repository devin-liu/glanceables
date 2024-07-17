import SwiftUI

struct CaptureRectangleView: View {
    @ObservedObject var captureMenuViewModel: WebPreviewCaptureMenuViewModel
    @ObservedObject var viewModel: WebClipEditorViewModel
    
    var body: some View {
        ZStack {
            if captureMenuViewModel.captureModeOn {
                if let clipRect = viewModel.currentClipRect {
                    if captureMenuViewModel.dragging {
                        Rectangle()
                            .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round, dash: [10, 5]))
                            .background(Color.black.opacity(0.1))
                            .frame(width: clipRect.width, height: clipRect.height)
                            .position(x: clipRect.midX, y: clipRect.midY)
                    }else{
                        //                        SaveButtonView {
                        //                            viewModel.saveURL(with: viewModel.screenShot)
                        //                        }
                        Rectangle()
                            .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round, dash: [10, 5]))
                            .frame(width: clipRect.width, height: clipRect.height)
                        //                            .position(x: clipRect.midX, y: clipRect.midY)
                            .overlay(
                                SaveButtonView {
                                    viewModel.saveURL(with: viewModel.screenShot)
                                }
                                    .offset(x: 10, y: 10)
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
