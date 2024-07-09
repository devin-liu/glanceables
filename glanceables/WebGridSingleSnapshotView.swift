import SwiftUI
import WebKit
import Combine

struct WebGridSingleSnapshotView: View {
    @State private var lastRefreshDate: Date = Date()
    @State private var timer: Timer?
    @State private var rotationAngle: Double = 0  // State variable for rotation angle
    @State private var reloadTrigger = PassthroughSubject<Void, Never>() // Local reload trigger
    
    @ObservedObject private var viewModel = WebClipEditorViewModel()
    let id: UUID
    
    private var item: WebClip? {
        return viewModel.webClip(withId: id)        
    }
    
    var body: some View {
        VStack {
            ZStack(alignment: .top) {
                if let screenshotPath = item?.screenshotPath, let image = viewModel.loadImage(from: screenshotPath) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .cornerRadius(16.0)
                }
                ScrollView {
                    if let id = item?.id, let originalSize = item?.originalSize {
                        WebViewSnapshotRefresher(id: id, reloadTrigger: reloadTrigger)
                            .frame(width: originalSize.width, height: 600)
                            .edgesIgnoringSafeArea(.all)
                    }
                    
                }
                .opacity(0)  // Make the ScrollView invisible
                .frame(width: 0, height: 0)  // Make the ScrollView occupy no space
            }
            .padding(10)
            
            Text(item?.pageTitle ?? "Loading...")
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
        lastRefreshDate = Date()
        reloadTrigger.send() // Trigger the reload for this instance
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
    
    private func loadImage(from path: String?) -> UIImage? {
        guard let path = path else { return nil }
        let url = URL(fileURLWithPath: path)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }
}
