import UIKit

struct SnapshotTimelineModel: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let innerText: String
    let snapshotImage: UIImage

    enum CodingKeys: String, CodingKey {
        case id, timestamp, innerText, snapshotImage
    }

    init(id: UUID = UUID(), timestamp: Date, innerText: String, snapshotImage: UIImage) {
        self.id = id
        self.timestamp = timestamp
        self.innerText = innerText
        self.snapshotImage = snapshotImage
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        innerText = try container.decode(String.self, forKey: .innerText)
        let imageData = try container.decode(Data.self, forKey: .snapshotImage)
        guard let image = UIImage(data: imageData) else {
            throw DecodingError.dataCorruptedError(forKey: .snapshotImage, in: container, debugDescription: "Cannot decode image data")
        }
        snapshotImage = image
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(innerText, forKey: .innerText)
        guard let imageData = snapshotImage.pngData() else {
            throw EncodingError.invalidValue(snapshotImage, EncodingError.Context(codingPath: [CodingKeys.snapshotImage], debugDescription: "Cannot encode image"))
        }
        try container.encode(imageData, forKey: .snapshotImage)
    }
}
