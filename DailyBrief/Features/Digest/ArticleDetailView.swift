import SwiftUI

@MainActor
struct ArticleDetailView: View {
    private enum SaveState {
        case loading
        case saved
        case unsaved
        case failure
    }

    let item: DigestItem
    let savedArticles: SavedArticlesFeatureModel
    @State private var saveState: SaveState = .loading

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(item.sourceName.uppercased())
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tint)

                Text(item.title)
                    .font(.largeTitle.bold())

                Text(item.publishedAt, format: .dateTime.month(.wide).day().year())
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(item.summary)
                    .font(.body)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Why it matters")
                        .font(.headline)
                    Text(item.whyItMatters)
                }

                saveButton

                Link(destination: item.sourceURL) {
                    Label("Open original article", systemImage: "arrow.up.right.square")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityHint("Opens the article in your browser")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .navigationTitle("Article")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadSaveState()
        }
    }

    @ViewBuilder
    private var saveButton: some View {
        switch saveState {
        case .loading:
            ProgressView("Checking saved status")
        case .saved:
            Button("Remove from saved", systemImage: "bookmark.slash") {
                Task { await removeArticle() }
            }
            .buttonStyle(.bordered)
            .accessibilityHint("Removes this article from saved articles")
        case .unsaved:
            Button("Save article", systemImage: "bookmark") {
                Task { await saveArticle() }
            }
            .buttonStyle(.bordered)
            .accessibilityHint("Saves this article for later")
        case .failure:
            Button("Try saving again") {
                Task { await loadSaveState() }
            }
            .buttonStyle(.bordered)
            .accessibilityHint("Checks whether this article is saved")
        }
    }

    private func loadSaveState() async {
        do {
            saveState = try await savedArticles.contains(id: item.id) ? .saved : .unsaved
        } catch {
            saveState = .failure
        }
    }

    private func saveArticle() async {
        do {
            try await savedArticles.save(SavedArticle(item: item, savedAt: .now))
            saveState = .saved
        } catch {
            saveState = .failure
        }
    }

    private func removeArticle() async {
        do {
            try await savedArticles.remove(id: item.id)
            saveState = .unsaved
        } catch {
            saveState = .failure
        }
    }
}
