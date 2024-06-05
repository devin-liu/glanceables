import SwiftUI

@main
struct glanceablesApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(ViewPositionManager())  // Provide the manager to your view hierarchy
        }
    }
}
