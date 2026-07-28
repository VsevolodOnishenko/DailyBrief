import Foundation
import Observation

@MainActor
@Observable
final class SavedArticlesFeatureModel {
    enum State: Equatable {
        case idle
        case loading
        case content([SavedArticle])
        case empty
        case failure(String)
    }

    private(set) var state: State = .idle
    private let repository: any SavedArticlesRepository

    init(repository: any SavedArticlesRepository) {
        self.repository = repository
    }

    func load() async {
        state = .loading

        do {
            try await refresh()
        } catch {
            state = .failure("Saved articles could not be loaded.")
        }
    }

    func contains(id: UUID) async throws -> Bool {
        try await repository.contains(id: id)
    }

    func save(_ article: SavedArticle) async throws {
        try await repository.save(article)
        try await refresh()
    }

    func remove(id: UUID) async throws {
        try await repository.remove(id: id)
        try await refresh()
    }

    private func refresh() async throws {
        let articles = try await repository.loadAll()
        state = articles.isEmpty ? .empty : .content(articles)
    }
}
