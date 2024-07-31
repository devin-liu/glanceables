import UIKit

struct SnapshotTimelineModel: Identifiable {
    let id = UUID()
    let timestamp: Date
    let innerText: String
    let snapshotImage: UIImage
}
