import SwiftUI
import WebKit
import Combine

struct WebGridSingleSnapshotView: View {
    private var id: UUID
    @State private var urlString: String
    @State private var url: URL
    @State private var pageTitle: String = "Loading..."
    @State private var lastRefreshDate: Date = Date()
    @State private var timer: Timer?
    @State private var clipRect: CGRect?  // To store the coordinates of the selected area
    @State private var originalSize: CGSize?
    @State private var screenshot: UIImage?
    @State private var userInteracting: Bool = false
    @State private var rotationAngle: Double = 0  // State variable for rotation angle
    @State private var reloadTrigger = PassthroughSubject<Void, Never>() // Local reload trigger
    
    @Binding var item: WebViewItem
    
    init(item: Binding<WebViewItem>) {
        _item = item
        id = item.id
        _urlString = State(initialValue: item.wrappedValue.url.absoluteString)
        _url = State(initialValue: item.wrappedValue.url)
        _clipRect = State(initialValue: item.wrappedValue.clipRect)  // Initialize clipRect from the item
        _originalSize = State(initialValue: item.wrappedValue.originalSize)
        _screenshot = State(initialValue: WebGridSingleSnapshotView.loadImage(from: item.wrappedValue.screenshotPath))
    }
    
    var body: some View {
        VStack {
            ZStack(alignment: .top) {
                if let screenshot = screenshot {
                    Image(uiImage: screenshot)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .cornerRadius(16.0)
                }
                WebViewSnapshotRefresher(url: $url, pageTitle: $pageTitle, clipRect: $clipRect, originalSize: $originalSize, screenshot: $screenshot, item: $item, reloadTrigger: reloadTrigger, onScreenshotTaken: { newPath in
                    updateScreenshotPath(id, newPath)
                })
                .frame(width: originalSize?.width, height: 0)
                .edgesIgnoringSafeArea(.all)
            }            
            .padding(10)
            
            Text(pageTitle)
                .font(.headline)
                .lineLimit(1)
                .truncationMode(.tail)
                .padding()
            
            HStack {
                Image(systemName: "arrow.clockwise.circle.fill")
                    .foregroundColor(.gray)
                    .rotationEffect(.degrees(rotationAngle))  // Apply rotation effect
                    .animation(Animation.easeInOut(duration: 0.5), value: rotationAngle)
                
                
                
                Text(timeAgoSinceDate(lastRefreshDate))
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding()
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation {
                    rotationAngle += 360  // Rotate by 360 degrees
                }
                reloadWebView()
            }
        }
        .cornerRadius(8)
        .padding()
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            reloadWebView()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func reloadWebView() {
        if !userInteracting {
            lastRefreshDate = Date()
            reloadTrigger.send() // Trigger the reload for this instance
        }
    }
    
    private func timeAgoSinceDate(_ date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        if interval < 60 {
            return "Just now"
        }
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .hour, .day]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .full
        return formatter.string(from: interval) ?? "Just now"
    }
    
    
    private func updateScreenshotPath(_ id: UUID, _ newPath: String) {
        // Update the screenshotPath property of the item
        if(UserDefaultsManager.shared.webViewItemIDExists(id)){
            var updatedItem = item
            updatedItem.screenshotPath = newPath
            
            // Update the image displayed in the view
            screenshot = WebGridSingleSnapshotView.loadImage(from: newPath)
            
            // Save the updated item using your user defaults manager
            UserDefaultsManager.shared.updateWebViewItem(updatedItem)
            
            // Update the bound item to trigger UI updates if needed
            item = updatedItem
        }
        
    }
    
    
    private static func loadImage(from path: String?) -> UIImage? {
        guard let path = path else { return nil }
        let url = URL(fileURLWithPath: path)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }
}
