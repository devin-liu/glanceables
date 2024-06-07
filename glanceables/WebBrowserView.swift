import SwiftUI
import WebKit

struct WebBrowserView: View {
    @State private var urlString: String
    @State private var url: URL
    @State private var pageTitle: String = "Loading..."
    @State private var lastRefreshDate: Date = Date()
    @State private var timer: Timer?
    @State private var selectionRectangle: CGRect?  // To store the coordinates of the selected area

    var item: WebViewItem

    init(item: WebViewItem) {
        self.item = item
        _urlString = State(initialValue: item.url.absoluteString)
        _url = State(initialValue: item.url)
    }

    var body: some View {
        VStack {
            ZStack(alignment: .top) {
                WebView(url: $url, pageTitle: $pageTitle, selectionRectangle: $selectionRectangle)
                .frame(height: 300)
                .edgesIgnoringSafeArea(.all)

                if let selection = selectionRectangle {
                    // Optional: Visual overlay showing the selected area
                    Rectangle()
                        .frame(width: selection.width, height: selection.height)
                        .offset(x: selection.minX, y: selection.minY)
                        .border(Color.red, width: 2)
                        .opacity(0.5)
                }
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
