import Foundation
import Testing
@testable import DailyBriefDomain

struct SavedArticleTests {
    @Test
    func digestItemPreservesArticleContent() {
        let item = DigestItem(
            id: UUID(uuidString: "64E424CC-BA16-44EA-90B0-3BFD9B3A063D")!,
            title: "A useful article",
            summary: "A concise summary.",
            whyItMatters: "It informs an important decision.",
            sourceName: "Test Journal",
            sourceURL: URL(string: "https://example.com/article")!,
            publishedAt: Date(timeIntervalSince1970: 0)
        )

        #expect(SavedArticle(item: item, savedAt: .now).digestItem == item)
    }
}
