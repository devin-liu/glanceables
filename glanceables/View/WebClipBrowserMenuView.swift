import SwiftUI
import Combine

struct WebClipBrowserMenuView: View {
    @Environment(\.presentationMode) var presentationMode
    var webClipManager: WebClipManagerViewModel
    @ObservedObject var webClipSelector: WebClipSelectorViewModel
    @ObservedObject var pendingClip: WebClipCreatorViewModel
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    NavigationButtonsView(viewModel: pendingClip)
                        .padding(10)
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
                            if  let validURL = pendingClip.validURL {
                                WebViewScreenshotCapture(viewModel: pendingClip, captureMenuViewModel: webClipSelector, validURL: validURL)
                                    .frame(maxHeight: .infinity)
                                    .frame(width: geometry.size.width)
                                    .onDisappear {
                                        print("WebViewScreenshotCapture onDisappear")
                                    }
                                    .gesture(
                                        DragGesture(minimumDistance: 0)
                                            .onChanged { value in
                                                webClipSelector.startLocation = webClipSelector.startLocation ?? value.location
                                                webClipSelector.endLocation = value.location
                                                webClipSelector.dragging = true
                                                webClipSelector.dragEnded = false
                                                webClipSelector.updateClipRect(endLocation: value.location, bounds: geometry.size)
                                                pendingClip.currentClipRect = webClipSelector.currentClipRect
                                            }
                                            .onEnded { _ in
                                                webClipSelector.dragging = false
                                                webClipSelector.dragEnded = true
                                            }
                                    )
                            }
                            
                            if webClipSelector.captureModeOn {
                                CaptureRectangleView(captureMenuViewModel: webClipSelector, webClipManager: webClipManager, pendingClip: pendingClip)
                            }
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
                        self.presentationMode.wrappedValue.dismiss()
                    })
                    .padding(.top, -20)
                    .padding(.trailing, -20)
                }
                Spacer()
            }
        }
    }
}

struct WebPreviewCaptureMenuView_Previews: PreviewProvider {
    static var previewViewModel: WebClipCreatorViewModel = {
        let model = WebClipCreatorViewModel()
        model.urlString = "https://news.ycombinator.com/"
//        model.validateURL()
        return model
    }()
    static var previews: some View {
        WebClipBrowserMenuView(
            webClipManager: WebClipManagerViewModel(), webClipSelector: WebClipSelectorViewModel(), pendingClip: previewViewModel
        )
    }
}
