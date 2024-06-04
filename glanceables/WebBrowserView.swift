import SwiftUI
import WebKit

struct WebBrowserView: View {
    @State private var urlString: String
    @State private var url: URL
    @State private var pageTitle: String = "Loading..."
    @State private var timer: Timer?
    @State private var lastRefreshDate: Date = Date()

    init(url: URL) {
        self._url = State(initialValue: url)
        self._urlString = State(initialValue: url.absoluteString)
    }

    var body: some View {
        VStack {
            ZStack(alignment: .top) {
                WebView(url: $url, pageTitle: $pageTitle)
                    .frame(height: 300)
                    .edgesIgnoringSafeArea(.all)
            }
            .cornerRadius(16.0)
            .padding(10)

            Text(pageTitle)
                .font(.headline)
                .lineLimit(1) // Ensure the title is limited to one line
                .truncationMode(.tail) // Use truncation mode for overflow
                .padding()
            
            HStack {
                Image(systemName: "arrow.clockwise.circle.fill")
                    .foregroundColor(.gray)
                   
                Text(timeAgoSinceDate(lastRefreshDate))
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding()
        }
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
    }

    private func reloadWebView() {
        url = URL(string: urlString)!  // Ensure URL is valid
        lastRefreshDate = Date()
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

struct WebBrowserView_Previews: PreviewProvider {
    static var previews: some View {
        WebBrowserView(url: URL(string: "https://www.apple.com")!)
    }
}
