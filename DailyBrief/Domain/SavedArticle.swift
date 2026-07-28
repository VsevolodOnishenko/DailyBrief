import Foundation

nonisolated struct SavedArticle: Equatable, Hashable, Identifiable, Sendable {
    let id: UUID
    let title: String
    let summary: String
    let whyItMatters: String
    let sourceName: String
    let sourceURL: URL
    let publishedAt: Date
    let savedAt: Date

    init(
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

    init(item: DigestItem, savedAt: Date) {
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

    var digestItem: DigestItem {
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
