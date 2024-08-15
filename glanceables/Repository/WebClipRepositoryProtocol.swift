import Foundation

protocol WebClipRepositoryProtocol {
    static func loadWebClips() -> [WebClip]
    static func saveWebClips(_ webClips: [WebClip])
    static func deleteWebClip(_ webClip: WebClip)
    static func deleteWebClipById(_ id: UUID)
}
