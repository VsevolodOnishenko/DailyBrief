import SwiftUI
import DailyBriefDomain

@MainActor
struct SavedArticlesView: View {
    let model: SavedArticlesFeatureModel

    var body: some View {
        NavigationStack {
            Group {
                switch model.state {
                case .idle, .loading:
                    ProgressView("Loading saved articles")
                case .content(let articles):
                    savedArticlesContent(articles)
                case .empty:
                    ContentUnavailableView(
                        "No saved articles",
                        systemImage: "bookmark",
                        description: Text("Articles you save will appear here.")
                    )
                case .failure(let message):
                    ContentUnavailableView {
                        Label("Unable to load saved articles", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(message)
                    } actions: {
                        Button("Try Again") {
                            Task { await model.load() }
                        }
                    }
                }
            }
            .navigationTitle("Saved")
        }
        .task {
            guard model.state == .idle else { return }
            await model.load()
        }
    }

    private func savedArticlesContent(_ articles: [SavedArticle]) -> some View {
        List(articles) { article in
            NavigationLink {
                ArticleDetailView(item: article.digestItem, savedArticles: model)
            } label: {
                VStack(alignment: .leading, spacing: 6) {
                    Text(article.sourceName.uppercased())
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tint)

                    Text(article.title)
                        .font(.headline)

                    Text(article.summary)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(article.title). From \(article.sourceName).")
                .accessibilityHint("Opens saved article details")
            }
        }
        .listStyle(.plain)
    }
}
