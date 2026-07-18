import SwiftUI

struct ArticleDetailView: View {
    let item: DigestItem

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
    }
}
