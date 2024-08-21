import Foundation
import SwiftUI

class WebClipUpdaterViewModel: ObservableObject {
    @Published var pendingUpdates: [SnapshotUpdate] = []
    var webClip: WebClip
    
    init(webClip: WebClip) {
        self.webClip = webClip
    }
    
    
    func queueSnapshotUpdate(newSnapshot: String? = nil, innerText: String? = nil, conciseText: String? = nil) {        
        let update = SnapshotUpdate(newSnapshot: newSnapshot, innerText: innerText, conciseText: conciseText)
        pendingUpdates.append(update)
        processPendingUpdates()
    }
    
    private func processPendingUpdates() {
        // Initialize a dictionary to keep track of the first occurrence of each update component
        var fieldsDictionary: [String: String] = [:]
        
        // Iterate over all pending updates to merge them
        for update in pendingUpdates {
            // Collect only the first non-nil occurrence of each field
            if let innerText = update.innerText, fieldsDictionary["innerText"] == nil {
                fieldsDictionary["innerText"] = innerText
            }
            if let conciseText = update.conciseText, fieldsDictionary["conciseText"] == nil {
                fieldsDictionary["conciseText"] = conciseText
            }
            if let newSnapshot = update.newSnapshot, fieldsDictionary["newSnapshot"] == nil {
                fieldsDictionary["newSnapshot"] = newSnapshot
            }
        }
        
        // Check if we have collected all necessary fields
        if let innerText = fieldsDictionary["innerText"],
           let conciseText = fieldsDictionary["conciseText"],
           let newSnapshot = fieldsDictionary["newSnapshot"] {
            // If all required fields are present, process the update
            webClip.addSnapshotIfNeeded(screenshotPath: newSnapshot, innerText: innerText, conciseText: conciseText)
            pendingUpdates.removeAll()
        }
    }
}
