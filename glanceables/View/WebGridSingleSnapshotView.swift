import SwiftUI
import WebKit
import Combine

struct WebGridSingleSnapshotView: View {
    @State private var lastRefreshDate: Date = Date()
    @State private var timer: Timer?
    @State private var rotationAngle: Double = 0  // State variable for rotation angle
    @State private var reloadTrigger = PassthroughSubject<Void, Never>() // Local reload trigger
    @ObservedObject var item: WebClip
    @State var webClipManager: WebClipManagerViewModel
    
    var body: some View {
        VStack {
            ScreenshotView(item: item, webClipManager: webClipManager)
                .padding(10)
            
            PageTitleView(title: item.pageTitle ?? "Loading...")
                .padding()
            
            ConciseTextView(text: item.snapshots.last?.conciseText ?? item.snapshots.last?.innerText ?? " ")
                .padding()
            
            RefreshIconView(rotationAngle: $rotationAngle, lastRefreshDate: $lastRefreshDate, reloadTrigger: reloadTrigger)
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
        lastRefreshDate = Date()
        reloadTrigger.send() // Trigger the reload for this instance
    }
}

struct ScreenshotView: View {
    @ObservedObject var item: WebClip
    var webClipManager: WebClipManagerViewModel
    
    var body: some View {
        ZStack(alignment: .top) {
            if let screenshotPath = item.screenshotPath {
                AsyncImageView(imagePath: screenshotPath)
            }
            ScrollView {
                WebViewSnapshotRefresher(viewModel: webClipManager, webClip: item)
                    .frame(width: item.originalSize?.width, height: 600)
                    .edgesIgnoringSafeArea(.all)
            }
            .opacity(0)  // Make the ScrollView invisible
            .frame(width: 0, height: 0)  // Make the ScrollView occupy no space
        }
    }
}


struct PageTitleView: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.headline)
            .lineLimit(1)
            .truncationMode(.tail)
    }
}

struct ConciseTextView: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.caption)
    }
}

struct RefreshIconView: View {
    @Binding var rotationAngle: Double
    @Binding var lastRefreshDate: Date
    let reloadTrigger: PassthroughSubject<Void, Never>
    
    var body: some View {
        HStack {
            Image(systemName: "arrow.clockwise.circle.fill")
                .foregroundColor(.gray)
                .rotationEffect(.degrees(rotationAngle))  // Apply rotation effect
                .animation(Animation.easeInOut(duration: 0.5), value: rotationAngle)
            
            Text(timeAgoSinceDate(lastRefreshDate))
                .font(.subheadline)
                .foregroundColor(.gray)
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
}


struct AsyncImageView: View {
    @StateObject private var imageLoader: ImageLoader
    let placeholder: Image
    
    // Updated to accept a file path as a String instead of a URL
    init(imagePath: String, placeholder: Image = Image(systemName: "photo")) {
        _imageLoader = StateObject(wrappedValue: ImageLoader(imagePath: imagePath))
        self.placeholder = placeholder
    }
    
    var body: some View {
        ZStack {
            if let image = imageLoader.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .cornerRadius(24)
            } else {
                placeholder
                    .resizable()
                    .scaledToFit()
            }
        }
        .onAppear {
            imageLoader.load()
        }
    }
}


class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private let imagePath: String
    
    init(imagePath: String) {
        self.imagePath = imagePath
    }
    
    func load() {
        DispatchQueue.global(qos: .background).async {
            if let data = FileManager.default.contents(atPath: self.imagePath),
               let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = image
                }
            } else {
                // Log error or handle the scenario where the image could not be loaded
                print("Failed to load image from path: \(self.imagePath)")
            }
        }
    }
}
