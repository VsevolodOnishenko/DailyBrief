import Foundation
import Testing
@testable import DailyBrief

@MainActor
struct DigestFeatureModelTests {
    @Test
    func successfulLoadTransitionsToContent() async {
        let digest = makeDigest(items: [makeItem()])
        let model = DigestFeatureModel(repository: StubDigestRepository(result: .success(digest)))

        #expect(model.state == .idle)
        await model.load()

        #expect(model.state == .content(digest))
    }

    @Test
    func digestWithoutArticlesTransitionsToEmpty() async {
        let model = DigestFeatureModel(
            repository: StubDigestRepository(result: .success(makeDigest(items: [])))
        )

        await model.load()

        #expect(model.state == .empty)
    }

    @Test
    func repositoryErrorTransitionsToFailure() async {
        let model = DigestFeatureModel(
            repository: StubDigestRepository(result: .failure(TestError.unavailable))
        )

        await model.load()

        #expect(model.state == .failure("Today's digest could not be loaded."))
    }

    @Test
    func loadTransitionsThroughLoading() async {
        let repository = ControlledDigestRepository()
        let model = DigestFeatureModel(repository: repository)
        let task = Task { await model.load() }

        await Task.yield()
        #expect(model.state == .loading)

        await repository.resume(returning: makeDigest(items: [makeItem()]))
        await task.value
        #expect(model.state != .loading)
    }

    private func makeDigest(items: [DigestItem]) -> DailyDigest {
        DailyDigest(date: Date(timeIntervalSince1970: 0), items: items)
    }

    private func makeItem() -> DigestItem {
        DigestItem(
            id: UUID(uuidString: "64E424CC-BA16-44EA-90B0-3BFD9B3A063D")!,
            title: "A useful article",
            summary: "A concise summary.",
            whyItMatters: "It informs an important decision.",
            sourceName: "Test Journal",
            sourceURL: URL(string: "https://example.com/article")!,
            publishedAt: Date(timeIntervalSince1970: 0)
        )
    }
}

private struct StubDigestRepository: DigestRepository {
    let result: Result<DailyDigest, Error>

    func fetchDailyDigest() async throws -> DailyDigest {
        try result.get()
    }
}

private actor ControlledDigestRepository: DigestRepository {
    private var continuation: CheckedContinuation<DailyDigest, Error>?

    func fetchDailyDigest() async throws -> DailyDigest {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
        }
    }

    func resume(returning digest: DailyDigest) async {
        while continuation == nil {
            await Task.yield()
        }

        continuation?.resume(returning: digest)
        continuation = nil
    }
}

private enum TestError: Error {
    case unavailable
}
