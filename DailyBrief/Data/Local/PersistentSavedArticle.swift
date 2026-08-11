import Foundation
import SwiftData
import DailyBriefDomain

@Model
final class PersistentSavedArticle {
    @Attribute(.unique) var id: UUID
    var title: String
    var summary: String
    var whyItMatters: String
    var sourceName: String
    var sourceURL: URL
    var publishedAt: Date
    var savedAt: Date

    init(article: SavedArticle) {
        id = article.id
        title = article.title
        summary = article.summary
        whyItMatters = article.whyItMatters
        sourceName = article.sourceName
        sourceURL = article.sourceURL
        publishedAt = article.publishedAt
        savedAt = article.savedAt
    }

    var savedArticle: SavedArticle {
        SavedArticle(
            id: id,
            title: title,
            summary: summary,
            whyItMatters: whyItMatters,
            sourceName: sourceName,
            sourceURL: sourceURL,
            publishedAt: publishedAt,
            savedAt: savedAt
        )
    }
}
