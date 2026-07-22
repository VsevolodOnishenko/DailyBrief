import Foundation
import Testing
@testable import DailyBrief

struct FileDigestStoreTests {
    @Test
    func savedDigestCanBeLoaded() async throws {
        let fileURL = makeFileURL()
        defer { try? FileManager.default.removeItem(at: fileURL) }

        let store = FileDigestStore(fileURL: fileURL)
        let storedDigest = StoredDigest(digest: makeDigest(), savedAt: savedAt)

        try await store.save(storedDigest)

        #expect(try await store.load() == storedDigest)
    }

    @Test
    func missingFileReturnsNoDigest() async throws {
        let fileURL = makeFileURL()
        defer { try? FileManager.default.removeItem(at: fileURL) }

        let store = FileDigestStore(fileURL: fileURL)

        #expect(try await store.load() == nil)
    }

    @Test
    func invalidFileReportsInvalidCache() async throws {
        let fileURL = makeFileURL()
        defer { try? FileManager.default.removeItem(at: fileURL) }
        try Data("not json".utf8).write(to: fileURL)

        let store = FileDigestStore(fileURL: fileURL)

        await #expect(throws: FileDigestStoreError.invalidCache) {
            try await store.load()
        }
    }

    private func makeFileURL() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("json")
    }

    private func makeDigest() -> DailyDigest {
        DailyDigest(
            date: savedAt,
            items: [
                DigestItem(
                    id: UUID(uuidString: "64E424CC-BA16-44EA-90B0-3BFD9B3A063D")!,
                    title: "A useful article",
                    summary: "A concise summary.",
                    whyItMatters: "It informs an important decision.",
                    sourceName: "Test Journal",
                    sourceURL: URL(string: "https://example.com/article")!,
                    publishedAt: savedAt
                )
            ]
        )
    }

    private var savedAt: Date {
        Date(timeIntervalSince1970: 1_784_160_000)
    }
}
