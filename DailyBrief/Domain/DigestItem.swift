import Foundation

nonisolated struct DigestItem: Codable, Equatable, Hashable, Identifiable, Sendable {
    let id: UUID
    let title: String
    let summary: String
    let whyItMatters: String
    let sourceName: String
    let sourceURL: URL
    let publishedAt: Date
}
