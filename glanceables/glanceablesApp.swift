import SwiftUI

@main
struct glanceablesApp: App {
    @State private var webClipManager = WebClipManagerViewModel()

    init() {
        NotificationManager.requestAuthorization()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(webClipManager)

        }
    }
}

private struct webClipManagerKey: EnvironmentKey {
    static var defaultValue: WebClipManagerViewModel = WebClipManagerViewModel()
    
    typealias Value = WebClipManagerViewModel
    
    static let webClipManager: WebClipManagerViewModel = WebClipManagerViewModel()
}

extension EnvironmentValues {
    var webClipManager: WebClipManagerViewModel {
        get { self[webClipManagerKey.self] }
        set { self[webClipManagerKey.self] = newValue }
    }
}
