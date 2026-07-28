import SwiftUI

@MainActor
struct DigestFeedView: View {
    @State private var model: DigestFeatureModel
    private let savedArticles: SavedArticlesFeatureModel

    init(repository: any DigestRepository, savedArticles: SavedArticlesFeatureModel) {
        _model = State(initialValue: DigestFeatureModel(repository: repository))
        self.savedArticles = savedArticles
    }

    var body: some View {
        NavigationStack {
            Group {
                switch model.state {
                case .idle, .loading:
                    ProgressView("Loading today's digest")
                case .content(let digest):
                    digestContent(digest)
                case .empty:
                    ContentUnavailableView(
                        "No articles today",
                        systemImage: "newspaper",
                        description: Text("Check back later for the next digest.")
                    )
                case .failure(let message):
                    ContentUnavailableView {
                        Label("Unable to load digest", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(message)
                    } actions: {
                        Button("Try Again") {
                            Task { await model.load() }
                        }
                    }
                }
            }
            .navigationTitle("DailyBrief")
        }
        .task {
            guard model.state == .idle else { return }
            await model.load()
        }
    }

    private func digestContent(_ digest: DailyDigest) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                Text(digest.date, format: .dateTime.weekday(.wide).month(.wide).day())
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("Digest for \(digest.date.formatted(date: .long, time: .omitted))")

                ForEach(digest.items) { item in
                    NavigationLink(value: item) {
                        DigestCard(item: item)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .navigationDestination(for: DigestItem.self) { item in
            ArticleDetailView(item: item, savedArticles: savedArticles)
        }
    }
}

private struct DigestCard: View {
    let item: DigestItem

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(item.sourceName.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tint)

            Text(item.title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.primary)

            Text(item.summary)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineLimit(3)

            Label("Read article", systemImage: "chevron.right")
                .font(.caption.weight(.medium))
                .foregroundStyle(.tint)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.background.secondary, in: RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.title). From \(item.sourceName). \(item.summary)")
        .accessibilityHint("Opens article details")
    }
}
