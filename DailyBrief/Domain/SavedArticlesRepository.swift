import Foundation

nonisolated protocol SavedArticlesRepository: Sendable {
    func loadAll() async throws -> [SavedArticle]
    func contains(id: UUID) async throws -> Bool
    func save(_ article: SavedArticle) async throws
    func remove(id: UUID) async throws
}

nonisolated enum SavedArticlesRepositoryError: Error, Equatable, Sendable {
    case unavailable
}
