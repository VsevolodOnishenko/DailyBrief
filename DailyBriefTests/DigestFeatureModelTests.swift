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

    @Test
    func newerLoadCancelsEarlierLoadAndIgnoresItsResult() async {
        let repository = SequencedDigestRepository()
        let model = DigestFeatureModel(repository: repository)
        let first = Task { await model.load() }
        await repository.waitForRequest(at: 0)
        let second = Task { await model.load() }
        await repository.waitForRequest(at: 1)

        await repository.resume(requestAt: 0, with: .success(makeDigest(items: [makeItem(title: "Older")])))
        await Task.yield()
        #expect(model.state == .loading)

        let current = makeDigest(items: [makeItem(title: "Current")])
        await repository.resume(requestAt: 1, with: .success(current))
        await first.value
        await second.value
        #expect(model.state == .content(current))
    }

    @Test
    func cancelledLoadFailureCannotOverwriteNewerLoad() async {
        let repository = SequencedDigestRepository()
        let model = DigestFeatureModel(repository: repository)
        let first = Task { await model.load() }
        await repository.waitForRequest(at: 0)
        let second = Task { await model.load() }
        await repository.waitForRequest(at: 1)

        await repository.resume(requestAt: 0, with: .failure(TestError.unavailable))
        await Task.yield()
        #expect(model.state == .loading)

        let current = makeDigest(items: [makeItem(title: "Current")])
        await repository.resume(requestAt: 1, with: .success(current))
        await first.value
        await second.value
        #expect(model.state == .content(current))
    }

    @Test
    func cancellationErrorDoesNotBecomeFailure() async {
        let repository = SequencedDigestRepository()
        let model = DigestFeatureModel(repository: repository)
        let first = Task { await model.load() }
        await repository.waitForRequest(at: 0)
        let second = Task { await model.load() }
        await repository.waitForRequest(at: 1)

        await repository.resume(requestAt: 0, with: .failure(CancellationError()))
        await Task.yield()
        #expect(model.state == .loading)

        let current = makeDigest(items: [makeItem()])
        await repository.resume(requestAt: 1, with: .success(current))
        await first.value
        await second.value
        #expect(model.state == .content(current))
    }

    @Test
    func refreshSuccessKeepsContentVisibleAndCleansUp() async {
        let repository = SequencedDigestRepository()
        let model = DigestFeatureModel(repository: repository)
        let initial = makeDigest(items: [makeItem(title: "Initial")])
        let load = Task { await model.load() }
        await repository.waitForRequest(at: 0)
        await repository.resume(requestAt: 0, with: .success(initial))
        await load.value

        let refresh = Task { await model.refresh() }
        await repository.waitForRequest(at: 1)
        #expect(model.state == .content(initial))
        #expect(model.isRefreshing)

        let updated = makeDigest(items: [makeItem(title: "Updated")])
        await repository.resume(requestAt: 1, with: .success(updated))
        await refresh.value
        #expect(model.state == .content(updated))
        #expect(!model.isRefreshing)
    }

    @Test
    func refreshFailurePreservesContentAndCleansUp() async {
        let repository = SequencedDigestRepository()
        let model = DigestFeatureModel(repository: repository)
        let initial = makeDigest(items: [makeItem()])
        let load = Task { await model.load() }
        await repository.waitForRequest(at: 0)
        await repository.resume(requestAt: 0, with: .success(initial))
        await load.value

        let refresh = Task { await model.refresh() }
        await repository.waitForRequest(at: 1)
        await repository.resume(requestAt: 1, with: .failure(TestError.unavailable))
        await refresh.value
        #expect(model.state == .content(initial))
        #expect(!model.isRefreshing)
    }

    private func makeDigest(items: [DigestItem]) -> DailyDigest {
        DailyDigest(date: Date(timeIntervalSince1970: 0), items: items)
    }

    private func makeItem(title: String = "A useful article") -> DigestItem {
        DigestItem(
            id: UUID(uuidString: "64E424CC-BA16-44EA-90B0-3BFD9B3A063D")!,
            title: title,
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

private actor SequencedDigestRepository: DigestRepository {
    private var continuations: [CheckedContinuation<DailyDigest, Error>?] = []

    func fetchDailyDigest() async throws -> DailyDigest {
        try await withCheckedThrowingContinuation { continuations.append($0) }
    }

    func waitForRequest(at index: Int) async {
        while continuations.count <= index { await Task.yield() }
    }

    func resume(requestAt index: Int, with result: Result<DailyDigest, Error>) async {
        while continuations.count <= index || continuations[index] == nil { await Task.yield() }
        let continuation = continuations[index]
        continuations[index] = nil
        continuation?.resume(with: result)
    }
}

private enum TestError: Error {
    case unavailable
}
