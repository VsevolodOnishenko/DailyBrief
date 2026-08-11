import Foundation
import DailyBriefDomain

nonisolated struct StoredDigest: Codable, Equatable, Sendable {
    let digest: DailyDigest
    let savedAt: Date
}
