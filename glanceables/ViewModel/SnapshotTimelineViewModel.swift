import Combine
import UIKit

class SnapshotTimelineViewModel: ObservableObject {
    @Published var snapshotTimeline: [SnapshotTimelineModel] = []

    init() {
        fetchTimeline()
    }

    private func fetchTimeline() {
        snapshotTimeline = SnapshotTimelineManager.shared.fetchSnapshots()
    }

    func updateIfNeeded(newSnapshot: UIImage, innerText: String, for webClip: WebClip) {
        SnapshotTimelineManager.shared.addSnapshotIfNeeded(newSnapshot: newSnapshot, innerText: innerText, for: webClip)
        fetchTimeline()
    }
}
