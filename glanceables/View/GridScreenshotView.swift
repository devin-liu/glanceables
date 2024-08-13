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
            
            WebViewSnapshotRefresher(viewModel: webClipManager, webClip: item)
                .frame(width: item.originalSize?.width, height: 600)
                .edgesIgnoringSafeArea(.all)
                .opacity(0)  // Make the ScrollView invisible
                .frame(width: 0, height: 0)  // Make the ScrollView occupy no space
                .onDisappear {
                    print("WebViewSnapshotRefresher onDisappear")
                }
            
            
        }
    }
}
