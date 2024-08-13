import SwiftUI

struct CaptureRectangleView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var captureMenuViewModel = WebClipSelectorViewModel.shared
    var webClipManager: WebClipManagerViewModel
    @ObservedObject var pendingClip: WebClipCreatorViewModel
    
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
                    pendingClip.currentClipRect = captureMenuViewModel.currentClipRect
                    pendingClip.capturedElements = captureMenuViewModel.capturedElements
//                    TODOOO MAKE SURE NEW CAPTURED ELEMSNTE AND SNAPTSHOTS ARE SAVED
//                    MAKE SURE NEW WEB CLIPS CAN BE ADDED
//                    MAKE SURE SCREENSHOTS PERSIST
                    webClipManager.createWebClip(newClip: pendingClip.getNewClip())
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
        let creatorModel = WebClipCreatorViewModel()
//        creatorModel.currentClipRect = CGRect(
//            x: screenWidth / 2 - 150,
//            y: 100,
//            width: 300,
//            height: 300
//        )
        GeometryReader { geometry in
            let viewModel = WebClipManagerViewModel()
            let captureMenuViewModel = WebClipSelectorViewModel()
            let webClipManager = WebClipManagerViewModel()
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
         
//            captureMenuViewModel.captureModeOn = true
            
            CaptureRectangleView(
                captureMenuViewModel: captureMenuViewModel,
                webClipManager: webClipManager, pendingClip: creatorModel
            )
            .frame(width: screenWidth, height: screenHeight)
        }
    }
}
//
//struct CaptureRectangleView_Previews: PreviewProvider {
//    static var previews: some View {
//        GeometryReader { geometry in
//            let viewModel = WebClipManagerViewModel()
//            let captureMenuViewModel = WebClipSelectorViewModel()
//            let creatorModel = WebClipCreatorViewModel()
//            let screenWidth = geometry.size.width
//            let screenHeight = geometry.size.height
//            
////            viewModel.currentClipRect = CGRect(
////                x: screenWidth / 2 - 150,
////                y: 100,
////                width: 300,
////                height: 300
////            )
////            captureMenuViewModel.captureModeOn = true
//            
//            CaptureRectangleView(
//                captureMenuViewModel: captureMenuViewModel,
//                pendingClip: creatorModel
//            )
//            .frame(width: screenWidth, height: screenHeight)
//        }
//    }
//}
