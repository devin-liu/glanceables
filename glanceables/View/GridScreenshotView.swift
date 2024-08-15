import SwiftUI

struct GridScreenshotView: View {
    var webClipId: UUID
    var webClipManager: WebClipManagerViewModel
    
    var body: some View {
        ZStack(alignment: .top) {
            if let screenshotPath = webClipManager.webClip(webClipId)?.screenshotPath {
                AsyncImageView(imagePath: screenshotPath)
                    .onDisappear {
                        print("AsyncImageView onDisappear")
                    }
            }            
        }
    }
}
