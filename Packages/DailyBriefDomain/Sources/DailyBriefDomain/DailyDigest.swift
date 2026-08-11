import Foundation

public struct DailyDigest: Codable, Equatable, Sendable {
    public let date: Date
    public let items: [DigestItem]

    public init(date: Date, items: [DigestItem]) {
        self.date = date
        self.items = items
    }
}
