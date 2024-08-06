import UIKit

struct SnapshotTimelineModel: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let innerText: String
    let outerHTML: String?
    let snapshotImage: UIImage
    let conciseText: String?

    enum CodingKeys: String, CodingKey {
        case id, timestamp, innerText, outerHTML, snapshotImage, conciseText
    }

    init(id: UUID = UUID(), timestamp: Date, innerText: String, outerHTML: String? = nil, snapshotImage: UIImage, conciseText: String? = nil) {
        self.id = id
        self.timestamp = timestamp
        self.innerText = innerText
        self.outerHTML = outerHTML
        self.snapshotImage = snapshotImage
        self.conciseText = conciseText
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        innerText = try container.decode(String.self, forKey: .innerText)
        outerHTML = try container.decode(String.self, forKey: .outerHTML)
        let imageData = try container.decode(Data.self, forKey: .snapshotImage)
        guard let image = UIImage(data: imageData) else {
            throw DecodingError.dataCorruptedError(forKey: .snapshotImage, in: container, debugDescription: "Cannot decode image data")
        }
        snapshotImage = image
        conciseText = try container.decodeIfPresent(String.self, forKey: .conciseText)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(innerText, forKey: .innerText)
        try container.encode(outerHTML, forKey: .outerHTML)
        guard let imageData = snapshotImage.pngData() else {
            throw EncodingError.invalidValue(snapshotImage, EncodingError.Context(codingPath: [CodingKeys.snapshotImage], debugDescription: "Cannot encode image"))
        }
        try container.encode(imageData, forKey: .snapshotImage)
        try container.encodeIfPresent(conciseText, forKey: .conciseText)
    }
}
