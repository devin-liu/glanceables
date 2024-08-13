import Foundation

protocol WebClipRepositoryProtocol {
    func loadWebClips() -> [WebClip]
    mutating func saveWebClips(_ webClips: [WebClip])
    func deleteWebClip(_ webClip: WebClip)
    func deleteWebClipById(_ id: UUID)
}
