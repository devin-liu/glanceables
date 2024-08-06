protocol WebClipRepositoryProtocol {
    func loadWebClips() -> [WebClip]
    func saveWebClips(_ webClips: [WebClip])
    func deleteWebClip(_ webClip: WebClip)
}
