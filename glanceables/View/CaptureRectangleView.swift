import SwiftUI

struct CaptureRectangleView: View {
    @Environment(WebClipManagerViewModel.self) private var webClipManager
    var dismiss: DismissAction?
    @ObservedObject var captureMenuViewModel: WebClipSelectorViewModel
    var pendingClip: WebClipCreatorViewModel
    
    var body: some View {
        ZStack {
            if captureMenuViewModel.dragEnded {
                // Gray overlay
                GeometryReader { geometry in
                    if captureMenuViewModel.captureModeOn {
                        Path { path in
                            // Full screen rectangle
                            path.addRect(CGRect(origin: .zero, size: geometry.size))
                            
                            // Subtract the clip rectangle if it exists
                            if let clipRect = pendingClip.currentClipRect {
                                path.addRect(clipRect)
                            }
                        }
                        .fill(Color.gray.opacity(0.5), style: FillStyle(eoFill: true))
                        .edgesIgnoringSafeArea(.all)
                    }
                }
            }
            if captureMenuViewModel.captureModeOn {
                captureModeContent
            }
        }
    }
    
    
    @ViewBuilder
    private var captureModeContent: some View {
        if let clipRect = pendingClip.currentClipRect {
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
                pendingClip.finalizeClip()
                // Check if a web clip is selected and if it's in editing mode
                if let webClip = webClipManager.selectedWebClip(), webClipManager.isEditing {
                    // Call updateWebClip function with correct parameters
                    webClipManager.updateWebClip(withId: webClip.id,
                                                 newURL: pendingClip.validURL,
                                                 newClipRect: pendingClip.currentClipRect,
                                                 newScreenshotPath: pendingClip.screenShot.flatMap(ScreenshotUtils.saveScreenshotToLocalDirectory),
                                                 newPageTitle: pendingClip.pageTitle,
                                                 newCapturedElements: captureMenuViewModel.capturedElements)
                } else {
                    // Add a new web clip if no web clip is selected or not in editing mode
                    webClipManager.createWebClip(newClip: pendingClip.getNewClip())
                }
                if let dismiss {
                    dismiss()
                }
                
            }
            .offset(x: -10, y: -65)
            .onAppear {
                print("save button overlay appear")
            }
        } else {
            EmptyView()
        }
    }
}



struct CaptureRectangleView_Previews: PreviewProvider {
    @Environment(\.dismiss) private var dismiss
    static var previews: some View {
        let creatorModel = WebClipCreatorViewModel()
        
        GeometryReader { geometry in
            let captureMenuViewModel = WebClipSelectorViewModel()            
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            CaptureRectangleView(
                dismiss:nil, captureMenuViewModel: captureMenuViewModel,
                pendingClip: creatorModel
            )
            .frame(width: screenWidth, height: screenHeight)
        }
    }
}
