import SwiftUI

@main
struct glanceablesApp: App {
    init() {
        NotificationManager.requestAuthorization()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
