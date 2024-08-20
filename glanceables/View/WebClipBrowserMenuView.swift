import SwiftUI
import WebKit

struct WebClipBrowserMenuView: View {
    var webClipSelector: WebClipSelectorViewModel
    var dismiss: DismissAction
    var pendingClip:WebClipCreatorViewModel
    
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    //                    if let webView = webView {
                    //                        NavigationButtonsView(webView: webView)
                    //                            .padding(10)
                    //                    }
                    AddURLFormView(viewModel: pendingClip) // Create a new instance or pass as needed
                        .padding(10)
                }
                
                if let screenshot = pendingClip.screenShot, webClipSelector.showPreview {
                    Image(uiImage: screenshot)
                        .frame(width: 300, height: 300)
                        .padding()
                }
                
                if pendingClip.isURLValid && !webClipSelector.showPreview {
                    GeometryReader { geometry in
                        ZStack {
                            if  let validURL = pendingClip.validURLs.last {
                                WebViewScreenshotCapture(viewModel: pendingClip, captureMenuViewModel: webClipSelector, validURL: validURL)
                                    .frame(maxHeight: .infinity)
                                    .frame(width: geometry.size.width)
                                    .gesture(
                                        DragGesture(minimumDistance: 0)
                                            .onChanged { [weak webClipSelector, weak pendingClip] value in
                                                webClipSelector!.setStartLocation(webClipSelector?.startLocation ?? value.location)
                                                webClipSelector!.setEndLocation(value.location)
                                                // Note: We don't need to set dragging and dragEnded explicitly here,
                                                // as they're handled in the setStartLocation and setEndLocation methods
                                                webClipSelector!.updateClipRect(endLocation: value.location, bounds: geometry.size)
                                                pendingClip!.currentClipRect = webClipSelector?.currentClipRect
                                            }
                                            .onEnded {  [weak webClipSelector] _ in
                                                webClipSelector!.setDragging(false)
                                                webClipSelector!.setDragEnded(true)
                                            }
                                    )
                            }
                            
                            CaptureRectangleView(dismiss: dismiss, captureMenuViewModel: webClipSelector, pendingClip: pendingClip)
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
                        dismiss()
                    })
                    .padding(.top, -20)
                    .padding(.trailing, -20)
                }
                Spacer()
            }
        }
    }
}

//struct WebPreviewCaptureMenuView_Previews: PreviewProvider {
//    static var previewViewModel: WebClipCreatorViewModel = {
//        let model = WebClipCreatorViewModel()
//        model.urlString = "https://news.ycombinator.com/"
//        return model
//    }()
//
//    static var previews: some View {
//        let pendingClip = WebClipCreatorViewModel()
//        WebClipBrowserMenuView(webClipSelector: WebClipSelectorViewModel(), pendingClip: pendingClip
//        )
//    }
//}
