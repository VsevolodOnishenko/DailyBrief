import Foundation
import Testing
import DailyBriefDomain
@testable import DailyBrief

@MainActor
struct AnalyticsEventEmissionTests {
    @Test
    func refreshEmitsRefreshRequested() async {
        let analytics = AnalyticsRecorder()
        let model = DigestFeatureModel(
            repository: DigestRepositoryStub(result: .success(makeDigest())),
            analytics: analytics
        )

        await model.refresh()

        #expect(analytics.events == [.digestRefreshRequested])
    }

    @Test
    func saveEmitsArticleSavedAfterPersistenceSucceeds() async throws {
        let analytics = AnalyticsRecorder()
        let model = SavedArticlesFeatureModel(
            repository: SavedArticlesRepositoryStub(),
            analytics: analytics
        )

        try await model.save(makeArticle())

        #expect(analytics.events == [.articleSaved])
    }

    @Test
    func removeEmitsArticleRemovedAfterPersistenceSucceeds() async throws {
        let article = makeArticle()
        let analytics = AnalyticsRecorder()
        let model = SavedArticlesFeatureModel(
            repository: SavedArticlesRepositoryStub(articles: [article]),
            analytics: analytics
        )

        try await model.remove(id: article.id)

        #expect(analytics.events == [.articleRemoved])
    }

    @Test
    func failedSaveDoesNotEmitArticleSaved() async {
        let analytics = AnalyticsRecorder()
        let model = SavedArticlesFeatureModel(
            repository: SavedArticlesRepositoryStub(failsSaving: true),
            analytics: analytics
        )

        await #expect(throws: AnalyticsTestError.persistenceUnavailable) {
            try await model.save(makeArticle())
        }

        #expect(analytics.events.isEmpty)
    }

    private func makeDigest() -> DailyDigest {
        DailyDigest(date: .now, items: [])
    }

    private func makeArticle() -> SavedArticle {
        SavedArticle(
            id: UUID(uuidString: "64E424CC-BA16-44EA-90B0-3BFD9B3A063D")!,
            title: "A useful article",
            summary: "A concise summary.",
            whyItMatters: "It informs an important decision.",
            sourceName: "Test Journal",
            sourceURL: URL(string: "https://example.com/article")!,
            publishedAt: Date(timeIntervalSince1970: 0),
            savedAt: Date(timeIntervalSince1970: 0)
        )
    }
}

@MainActor
private final class AnalyticsRecorder: AnalyticsTracking {
    private(set) var events: [AnalyticsEvent] = []

    func track(_ event: AnalyticsEvent) {
        events.append(event)
    }
}

private struct DigestRepositoryStub: DigestRepository {
    let result: Result<DailyDigest, Error>

    func fetchDailyDigest() async throws -> DailyDigest {
        try result.get()
    }
}

private actor SavedArticlesRepositoryStub: SavedArticlesRepository {
    private var articles: [SavedArticle]
    private let failsSaving: Bool

    init(articles: [SavedArticle] = [], failsSaving: Bool = false) {
        self.articles = articles
        self.failsSaving = failsSaving
    }

    func loadAll() throws -> [SavedArticle] {
        articles
    }

    func contains(id: UUID) throws -> Bool {
        articles.contains { $0.id == id }
    }

    func save(_ article: SavedArticle) throws {
        if failsSaving {
            throw AnalyticsTestError.persistenceUnavailable
        }
        articles.append(article)
    }

    func remove(id: UUID) throws {
        articles.removeAll { $0.id == id }
    }
}

private enum AnalyticsTestError: Error, Equatable {
    case persistenceUnavailable
}
