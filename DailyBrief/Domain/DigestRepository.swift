protocol DigestRepository: Sendable {
    func fetchDailyDigest() async throws -> DailyDigest
}
