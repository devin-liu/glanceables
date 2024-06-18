import SwiftUI
import WebKit

struct WebGridSingleSnapshotView: View {
    @State private var urlString: String
    @State private var url: URL
    @State private var pageTitle: String = "Loading..."
    @State private var lastRefreshDate: Date = Date()
    @State private var timer: Timer?
    @State private var clipRect: CGRect?  // To store the coordinates of the selected area
    @State private var originalSize: CGSize?
    @State private var screenshot: UIImage?
    @State private var userInteracting: Bool = false
    
    var item: WebViewItem
    
    init(item: WebViewItem) {
        self.item = item
        _urlString = State(initialValue: item.url.absoluteString)
        _url = State(initialValue: item.url)
        _clipRect = State(initialValue: item.clipRect)  // Initialize clipRect from the item
        _originalSize = State(initialValue: item.originalSize)
        _screenshot = State(initialValue: WebGridSingleSnapshotView.loadImage(from: item.screenshotPath))
    }
    
    var body: some View {
        VStack {
            ZStack(alignment: .top) {
                //                if let screenshot = screenshot {
                //                    Image(uiImage: screenshot)
                //                        .resizable()
                //                        .scaledToFit()
                //                        .frame(height: 300)
                //                } else {
                //                    WebViewSnapshotRefresher(url: $url, pageTitle: $pageTitle, clipRect: $clipRect, originalSize: $originalSize, screenshot: $screenshot)
                //                        .frame(height: 300)
                //                        .edgesIgnoringSafeArea(.all)
                //                }
                
                
                
                if let screenshot = screenshot {
                    Image(uiImage: screenshot)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                }
                
                WebViewSnapshotRefresher(url: $url, pageTitle: $pageTitle, clipRect: $clipRect, originalSize: $originalSize, screenshot: $screenshot)
                    .frame(width: originalSize?.width, height: 0)                    
                    .edgesIgnoringSafeArea(.all)
                
                
                
            }
            .cornerRadius(16.0)
            .padding(10)
            
            Text(pageTitle)
                .font(.headline)
                .lineLimit(1)
                .truncationMode(.tail)
                .padding()
            
            HStack {
                Image(systemName: "arrow.clockwise.circle.fill")
                    .foregroundColor(.gray)
                Text(timeAgoSinceDate(lastRefreshDate))
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding()
            .contentShape(Rectangle())
            .onTapGesture {
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
        timer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { _ in
            reloadWebView()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func reloadWebView() {
        if !userInteracting {
            url = URL(string: urlString)!  // Ensure URL is valid
            lastRefreshDate = Date()
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
    
    private static func loadImage(from path: String?) -> UIImage? {
        guard let path = path else { return nil }
        let url = URL(fileURLWithPath: path)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }
}
