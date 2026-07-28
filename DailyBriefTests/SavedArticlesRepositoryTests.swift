import Foundation
import SwiftData
import Testing
@testable import DailyBrief

@MainActor
struct SavedArticlesRepositoryTests {
    @Test
    func saveThenLoadAllReturnsTheSavedArticle() async throws {
        let repository = try makeRepository()
        let article = makeArticle()

        try await repository.save(article)

        #expect(try await repository.loadAll() == [article])
        #expect(try await repository.contains(id: article.id))
    }

    @Test
    func savingTheSameArticleTwiceKeepsOneRecord() async throws {
        let repository = try makeRepository()
        let article = makeArticle()

        try await repository.save(article)
        try await repository.save(article)

        #expect(try await repository.loadAll() == [article])
    }

    @Test
    func removeMakesTheArticleUnavailable() async throws {
        let repository = try makeRepository()
        let article = makeArticle()

        try await repository.save(article)
        try await repository.remove(id: article.id)

        #expect(try await repository.loadAll().isEmpty)
        #expect(try await !repository.contains(id: article.id))
    }

    @Test
    func loadAllOrdersArticlesByMostRecentlySaved() async throws {
        let repository = try makeRepository()
        let earlierArticle = makeArticle(
            id: UUID(uuidString: "64E424CC-BA16-44EA-90B0-3BFD9B3A063D")!,
            savedAt: Date(timeIntervalSince1970: 100)
        )
        let laterArticle = makeArticle(
            id: UUID(uuidString: "2BBEB1A9-4567-4A31-8E14-0B4D6CB799A6")!,
            savedAt: Date(timeIntervalSince1970: 200)
        )

        try await repository.save(earlierArticle)
        try await repository.save(laterArticle)

        #expect(try await repository.loadAll() == [laterArticle, earlierArticle])
    }

    private func makeRepository() throws -> DefaultSavedArticlesRepository {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: PersistentSavedArticle.self,
            configurations: configuration
        )
        return DefaultSavedArticlesRepository(
            store: SwiftDataSavedArticlesStore(modelContainer: container)
        )
    }

    private func makeArticle(
        id: UUID = UUID(uuidString: "64E424CC-BA16-44EA-90B0-3BFD9B3A063D")!,
        savedAt: Date = Date(timeIntervalSince1970: 100)
    ) -> SavedArticle {
        SavedArticle(
            id: id,
            title: "A useful article",
            summary: "A concise summary.",
            whyItMatters: "It informs an important decision.",
            sourceName: "Test Journal",
            sourceURL: URL(string: "https://example.com/article")!,
            publishedAt: Date(timeIntervalSince1970: 0),
            savedAt: savedAt
        )
    }
}
