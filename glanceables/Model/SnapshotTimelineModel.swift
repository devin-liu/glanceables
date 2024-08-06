import UIKit

struct SnapshotTimelineModel: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let innerText: String
    let outerHTML: String?
    let snapshotImagePath: String
    let snapshotImage: UIImage?
    let conciseText: String?
    
    enum CodingKeys: String, CodingKey {
        case id, timestamp, innerText, outerHTML, snapshotImagePath, conciseText
    }
    
    init(id: UUID = UUID(), timestamp: Date, innerText: String, outerHTML: String? = nil, snapshotImagePath: String, conciseText: String? = nil) {
        self.id = id
        self.timestamp = timestamp
        self.innerText = innerText
        self.outerHTML = outerHTML
        self.snapshotImagePath = snapshotImagePath
        self.snapshotImage = UIImage(contentsOfFile: snapshotImagePath) // Initialize UIImage from local path
        self.conciseText = conciseText
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        innerText = try container.decode(String.self, forKey: .innerText)
        outerHTML = try container.decodeIfPresent(String.self, forKey: .outerHTML)
        snapshotImagePath = try container.decode(String.self, forKey: .snapshotImagePath)
        snapshotImage = UIImage(contentsOfFile: snapshotImagePath) // Initialize UIImage from local path during decoding
        conciseText = try container.decodeIfPresent(String.self, forKey: .conciseText)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(innerText, forKey: .innerText)
        try container.encodeIfPresent(outerHTML, forKey: .outerHTML)
        try container.encode(snapshotImagePath, forKey: .snapshotImagePath)
        try container.encodeIfPresent(conciseText, forKey: .conciseText)
    }
}


struct SnapshotUpdate {
    let newSnapshot: String?
    let innerText: String?
    let conciseText: String?
}
