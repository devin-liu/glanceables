import SwiftUI
import WebKit
import Combine

struct WebGridSingleSnapshotView: View {
    @State private var lastRefreshDate: Date = Date()
    @State private var timer: Timer?
    @State private var rotationAngle: Double = 0  // State variable for rotation angle
    @State private var reloadTrigger = PassthroughSubject<Void, Never>() // Local reload trigger
    
    @ObservedObject private var viewModel = WebClipEditorViewModel.shared
    let id: UUID
    
    private var item: WebClip? {
        return viewModel.webClip(withId: id)
    }
    
    var body: some View {
        VStack {
            ScreenshotView(item: item, viewModel: viewModel)
                .padding(10)
            
            PageTitleView(title: item?.pageTitle ?? "Loading...")
                .padding()
            
            ConciseTextView(text: item?.llamaResult?.conciseText ?? " ")
                .padding()
            
            RefreshView(rotationAngle: $rotationAngle, lastRefreshDate: $lastRefreshDate, reloadTrigger: reloadTrigger)
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
    let item: WebClip?
    let viewModel: WebClipEditorViewModel
    
    var body: some View {
        ZStack(alignment: .top) {
            if let screenshotPath = item?.screenshotPath, let image = viewModel.loadImage(from: screenshotPath) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .cornerRadius(24)
            }
            
            ScrollView {
                if let id = item?.id, let originalSize = item?.originalSize {
                    WebViewSnapshotRefresher(id: id, reloadTrigger: PassthroughSubject<Void, Never>())
                        .frame(width: originalSize.width, height: 600)
                        .edgesIgnoringSafeArea(.all)
                }
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

struct RefreshView: View {
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
