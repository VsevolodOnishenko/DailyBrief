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
    private let digestRepository: any DigestRepository
    private let savedArticlesRepository: any SavedArticlesRepository
    private let analytics: any AnalyticsTracking

    init() {
        digestRepository = Self.makeDigestRepository()
        analytics = NoOpAnalyticsTracker()

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
                repository: digestRepository,
                savedArticlesRepository: savedArticlesRepository,
                analytics: analytics
            )
        }
    }

    private static func makeDigestRepository() -> any DigestRepository {
        #if DEBUG
        guard let endpoint = URL(string: "http://localhost:8080/daily-digest") else {
            return BundledDigestRepository()
        }

        let cacheDirectory = FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        ).first ?? FileManager.default.temporaryDirectory
        let localStore = FileDigestStore(
            fileURL: cacheDirectory.appendingPathComponent("daily_digest.json")
        )
        let remoteRepository = RemoteDigestRepository(
            client: URLSessionHTTPClient(session: .shared),
            endpoint: endpoint
        )

        return OfflineFirstDigestRepository(
            localStore: localStore,
            remoteRepository: remoteRepository,
            freshnessPolicy: DigestFreshnessPolicy(calendar: .current),
            currentDate: { .now }
        )
        #else
        return BundledDigestRepository()
        #endif
    }
}
