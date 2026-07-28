//
//  DailyBriefApp.swift
//  DailyBrief
//
//  Created by Vsevolod Onishchenko on 17. 7. 2026..
//

import SwiftUI
import SwiftData

@main
@MainActor
struct DailyBriefApp: App {
    private let savedArticlesRepository: any SavedArticlesRepository

    init() {
        do {
            let container = try ModelContainer(for: PersistentSavedArticle.self)
            let store = SwiftDataSavedArticlesStore(modelContainer: container)
            savedArticlesRepository = DefaultSavedArticlesRepository(store: store)
        } catch {
            savedArticlesRepository = UnavailableSavedArticlesRepository()
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(
                repository: BundledDigestRepository(),
                savedArticlesRepository: savedArticlesRepository
            )
        }
    }
}
