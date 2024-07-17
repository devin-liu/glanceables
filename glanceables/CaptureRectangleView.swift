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
                    }
                    Rectangle()
                        .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round, dash: [10, 5]))
                        .frame(width: clipRect.width, height: clipRect.height)
                        .position(x: clipRect.midX, y: clipRect.midY)
                }
            }
        }
    }
}

// Dummy view models for preview purposes
class CaptureMenuViewModel: ObservableObject {
    @Published var captureModeOn: Bool = true
    @Published var dragging: Bool = true
}

class ViewModel: ObservableObject {
    @Published var currentClipRect: CGRect? = CGRect(x: 50, y: 50, width: 200, height: 150)
}

struct CaptureRectangleView_Previews: PreviewProvider {
    static var previews: some View {
        CaptureRectangleView(captureMenuViewModel: WebPreviewCaptureMenuViewModel(), viewModel: WebClipEditorViewModel())
    }
}
