import Foundation

public struct DigestItem: Codable, Equatable, Hashable, Identifiable, Sendable {
    public let id: UUID
    public let title: String
    public let summary: String
    public let whyItMatters: String
    public let sourceName: String
    public let sourceURL: URL
    public let publishedAt: Date

    public init(id: UUID, title: String, summary: String, whyItMatters: String, sourceName: String, sourceURL: URL, publishedAt: Date) {
        self.id = id
        self.title = title
        self.summary = summary
        self.whyItMatters = whyItMatters
        self.sourceName = sourceName
        self.sourceURL = sourceURL
        self.publishedAt = publishedAt
    }
}
