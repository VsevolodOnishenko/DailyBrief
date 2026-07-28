import Foundation
import SwiftData

@ModelActor
actor SwiftDataSavedArticlesStore: SavedArticlesStore {
    func loadAll() throws -> [SavedArticle] {
        let descriptor = FetchDescriptor<PersistentSavedArticle>(
            sortBy: [
                SortDescriptor(\PersistentSavedArticle.savedAt, order: .reverse),
                SortDescriptor(\PersistentSavedArticle.id)
            ]
        )
        return try modelContext.fetch(descriptor).map(\.savedArticle)
    }

    func contains(id: UUID) throws -> Bool {
        var descriptor = FetchDescriptor<PersistentSavedArticle>(
            predicate: #Predicate { article in
                article.id == id
            }
        )
        descriptor.fetchLimit = 1
        return try !modelContext.fetch(descriptor).isEmpty
    }

    func save(_ article: SavedArticle) throws {
        guard try !contains(id: article.id) else { return }

        modelContext.insert(PersistentSavedArticle(article: article))
        try modelContext.save()
    }

    func remove(id: UUID) throws {
        let descriptor = FetchDescriptor<PersistentSavedArticle>(
            predicate: #Predicate { article in
                article.id == id
            }
        )

        for article in try modelContext.fetch(descriptor) {
            modelContext.delete(article)
        }
        try modelContext.save()
    }
}
