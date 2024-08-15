import SwiftUI

struct GridScreenshotView: View {
    @ObservedObject var item: WebClip
    var webClipManager: WebClipManagerViewModel
    
    var body: some View {
        ZStack(alignment: .top) {
            if let screenshotPath = item.screenshotPath {
                AsyncImageView(imagePath: screenshotPath)
                    .onDisappear {
                        print("AsyncImageView onDisappear")
                    }
            }            
        }
    }
}
