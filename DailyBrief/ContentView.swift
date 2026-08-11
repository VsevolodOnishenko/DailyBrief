//
//  ContentView.swift
//  DailyBrief
//
//  Created by Vsevolod Onishchenko on 17. 7. 2026..
//

import SwiftUI
import DailyBriefDomain

@MainActor
struct ContentView: View {
    private let repository: any DigestRepository
    private let analytics: any AnalyticsTracking
    @State private var savedArticles: SavedArticlesFeatureModel

    init(
        repository: any DigestRepository,
        savedArticlesRepository: any SavedArticlesRepository,
        analytics: any AnalyticsTracking
    ) {
        self.repository = repository
        self.analytics = analytics
        _savedArticles = State(
            initialValue: SavedArticlesFeatureModel(
                repository: savedArticlesRepository,
                analytics: analytics
            )
        )
    }

    var body: some View {
        TabView {
            DigestFeedView(
                repository: repository,
                savedArticles: savedArticles,
                analytics: analytics
            )
                .tabItem {
                    Label("Today", systemImage: "newspaper")
                }

            SavedArticlesView(model: savedArticles)
                .tabItem {
                    Label("Saved", systemImage: "bookmark")
                }
        }
    }
}
