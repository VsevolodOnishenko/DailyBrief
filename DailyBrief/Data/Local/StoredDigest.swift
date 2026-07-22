import Foundation

nonisolated struct StoredDigest: Codable, Equatable, Sendable {
    let digest: DailyDigest
    let savedAt: Date
}
