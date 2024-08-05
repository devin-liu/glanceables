import SwiftUI

struct CaptureRectangleView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var captureMenuViewModel: WebClipSelectorViewModel
    @ObservedObject var webClipEditor: WebClipManagerViewModel
    @ObservedObject var dashboardViewModel = DashboardViewModel.shared
    
    var body: some View {
        ZStack {
            if captureMenuViewModel.dragEnded {
                // Gray overlay
                GeometryReader { geometry in
                    Path { path in
                        // Full screen rectangle
                        path.addRect(CGRect(origin: .zero, size: geometry.size))
                        
                        // Subtract the clip rectangle if it exists
                        if let clipRect = webClipEditor.currentClipRect {
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
        if let clipRect = webClipEditor.currentClipRect {
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
                // Check if a web clip is selected and if it's in editing mode
                if let webClip = webClipEditor.selectedWebClip(), webClipEditor.isEditing {
                    // Call updateWebClip function with correct parameters
                    webClipEditor.updateWebClip(withId: webClip.id,
                                                newURL: webClipEditor.validURL,
                                                newClipRect: webClipEditor.currentClipRect,
                                                newScreenshotPath: webClipEditor.screenShot.flatMap(ScreenshotUtils.saveScreenshotToLocalDirectory),
                                                newPageTitle: webClipEditor.pageTitle,
                                                newCapturedElements: captureMenuViewModel.capturedElements)
                } else {
                    // Add a new web clip if no web clip is selected or not in editing mode
                    webClipEditor.addWebClip(screenshot: webClipEditor.screenShot,
                                             capturedElements: captureMenuViewModel.capturedElements, snapshots: nil)
                }
                self.presentationMode.wrappedValue.dismiss()
                
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
            let viewModel = WebClipManagerViewModel()
            let captureMenuViewModel = WebClipSelectorViewModel()
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
                webClipEditor: viewModel
            )
            .frame(width: screenWidth, height: screenHeight)
        }
    }
}


