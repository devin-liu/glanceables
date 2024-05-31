import SwiftUI

@main
struct glanceablesApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}


////
////  glanceablesApp.swift
////  glanceables
////
////  Created by Devin Liu on 5/30/24.
////
//
//import SwiftUI
//import SwiftData
//
//@main
//struct glanceablesApp: App {
//    var sharedModelContainer: ModelContainer = {
//        let schema = Schema([
//            Item.self,
//        ])
//        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
//
//        do {
//            return try ModelContainer(for: schema, configurations: [modelConfiguration])
//        } catch {
//            fatalError("Could not create ModelContainer: \(error)")
//        }
//    }()
//
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//        .modelContainer(sharedModelContainer)
//    }
//}
