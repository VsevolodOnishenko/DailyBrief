//
//  ContentView.swift
//  DailyBrief
//
//  Created by Vsevolod Onishchenko on 17. 7. 2026..
//

import SwiftUI

@MainActor
struct ContentView: View {
    private let repository: any DigestRepository
    @State private var savedArticles: SavedArticlesFeatureModel

    init(
        repository: any DigestRepository,
        savedArticlesRepository: any SavedArticlesRepository
    ) {
        self.repository = repository
        _savedArticles = State(
            initialValue: SavedArticlesFeatureModel(repository: savedArticlesRepository)
        )
    }

    var body: some View {
        TabView {
            DigestFeedView(repository: repository, savedArticles: savedArticles)
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
