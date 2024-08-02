import UIKit

class SnapshotTimelineManager {
    static let shared = SnapshotTimelineManager()
    private(set) var snapshots: [SnapshotTimelineModel] = []

    func addSnapshotIfNeeded(newSnapshot: UIImage, innerText: String, for webClip: WebClip) {
        if let lastSnapshot = snapshots.last, lastSnapshot.innerText == innerText {
            return
        }
        let newSnapshotModel = SnapshotTimelineModel(timestamp: Date(), innerText: innerText, snapshotImage: newSnapshot)
        snapshots.append(newSnapshotModel)
        
        NotificationManager.shared.sendNotification(title: webClip.pageTitle!, body: innerText)
    }

    func fetchSnapshots() -> [SnapshotTimelineModel] {
        return snapshots
    }
}
