import UIKit

class SnapshotTimelineManager {
    static let shared = SnapshotTimelineManager()
    private(set) var snapshots: [SnapshotTimelineModel] = []

    func addSnapshotIfNeeded(newSnapshot: UIImage, innerText: String) {
        guard let lastSnapshot = snapshots.last, lastSnapshot.innerText != innerText else {
            return
        }
        let newSnapshotModel = SnapshotTimelineModel(timestamp: Date(), innerText: innerText, snapshotImage: newSnapshot)
        snapshots.append(newSnapshotModel)
        
        NotificationManager.shared.sendNotification(title: "New Snapshot Captured", body: "A new snapshot has been captured and saved.")
    }

    func fetchSnapshots() -> [SnapshotTimelineModel] {
        return snapshots
    }
}
