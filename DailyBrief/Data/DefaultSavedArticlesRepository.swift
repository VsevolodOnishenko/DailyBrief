import Foundation
import DailyBriefDomain

nonisolated struct DefaultSavedArticlesRepository: SavedArticlesRepository {
    private let store: any SavedArticlesStore

    init(store: any SavedArticlesStore) {
        self.store = store
    }

    @concurrent
    func loadAll() async throws -> [SavedArticle] {
        try await store.loadAll()
    }

    @concurrent
    func contains(id: UUID) async throws -> Bool {
        try await store.contains(id: id)
    }

    @concurrent
    func save(_ article: SavedArticle) async throws {
        try await store.save(article)
    }

    @concurrent
    func remove(id: UUID) async throws {
        try await store.remove(id: id)
    }
}

nonisolated struct UnavailableSavedArticlesRepository: SavedArticlesRepository {
    @concurrent
    func loadAll() async throws -> [SavedArticle] {
        throw SavedArticlesRepositoryError.unavailable
    }

    @concurrent
    func contains(id: UUID) async throws -> Bool {
        throw SavedArticlesRepositoryError.unavailable
    }

    @concurrent
    func save(_ article: SavedArticle) async throws {
        throw SavedArticlesRepositoryError.unavailable
    }

    @concurrent
    func remove(id: UUID) async throws {
        throw SavedArticlesRepositoryError.unavailable
    }
}
