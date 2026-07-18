import Foundation

struct DailyDigest: Codable, Equatable, Sendable {
    let date: Date
    let items: [DigestItem]
}
