import Foundation
import DailyBriefDomain

nonisolated protocol SavedArticlesStore: Sendable {
    func loadAll() async throws -> [SavedArticle]
    func contains(id: UUID) async throws -> Bool
    func save(_ article: SavedArticle) async throws
    func remove(id: UUID) async throws
}
