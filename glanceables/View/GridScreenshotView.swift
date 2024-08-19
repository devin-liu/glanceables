import SwiftUI

struct GridScreenshotView: View {
    @Environment(WebClipManagerViewModel.self) private var webClipManager
    var webClipId: UUID
    
    var body: some View {
        ZStack(alignment: .top) {
            if let screenshotPath = webClipManager.webClip(webClipId)?.screenshotPath {
                AsyncImageView(imagePath: screenshotPath)                    
            }            
        }
    }
}
