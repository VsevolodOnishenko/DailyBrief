import Foundation

public struct SavedArticle: Equatable, Hashable, Identifiable, Sendable {
    public let id: UUID
    public let title: String
    public let summary: String
    public let whyItMatters: String
    public let sourceName: String
    public let sourceURL: URL
    public let publishedAt: Date
    public let savedAt: Date

    public init(
        id: UUID,
        title: String,
        summary: String,
        whyItMatters: String,
        sourceName: String,
        sourceURL: URL,
        publishedAt: Date,
        savedAt: Date
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.whyItMatters = whyItMatters
        self.sourceName = sourceName
        self.sourceURL = sourceURL
        self.publishedAt = publishedAt
        self.savedAt = savedAt
    }

    public init(item: DigestItem, savedAt: Date) {
        self.init(
            id: item.id,
            title: item.title,
            summary: item.summary,
            whyItMatters: item.whyItMatters,
            sourceName: item.sourceName,
            sourceURL: item.sourceURL,
            publishedAt: item.publishedAt,
            savedAt: savedAt
        )
    }

    public var digestItem: DigestItem {
        DigestItem(
            id: id,
            title: title,
            summary: summary,
            whyItMatters: whyItMatters,
            sourceName: sourceName,
            sourceURL: sourceURL,
            publishedAt: publishedAt
        )
    }
}
