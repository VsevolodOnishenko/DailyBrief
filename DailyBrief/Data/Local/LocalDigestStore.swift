nonisolated protocol LocalDigestStore: Sendable {
    func load() async throws -> StoredDigest?
    func save(_ storedDigest: StoredDigest) async throws
}
