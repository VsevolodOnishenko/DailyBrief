import Foundation
import Testing
import DailyBriefDomain
@testable import DailyBrief

struct OfflineFirstDigestRepositoryTests {
    @Test
    func freshCacheReturnsCachedDigestWithoutLoadingRemote() async throws {
        let cachedDigest = makeDigest(title: "Cached")
        let store = LocalDigestStoreSpy(
            loadBehavior: .stored(StoredDigest(digest: cachedDigest, savedAt: currentDate))
        )
        let remote = DigestRepositoryStub(result: .success(makeDigest(title: "Remote")))
        let repository = makeRepository(localStore: store, remoteRepository: remote)

        let digest = try await repository.fetchDailyDigest()

        #expect(digest == cachedDigest)
        #expect(await store.loadCallCount() == 1)
        #expect(await store.saveCallCount() == 0)
        #expect(await remote.callCount() == 0)
    }

    @Test
    func missingCacheLoadsAndSavesRemoteDigest() async throws {
        let remoteDigest = makeDigest(title: "Remote")
        let store = LocalDigestStoreSpy(loadBehavior: .missing)
        let remote = DigestRepositoryStub(result: .success(remoteDigest))
        let repository = makeRepository(localStore: store, remoteRepository: remote)

        let digest = try await repository.fetchDailyDigest()

        #expect(digest == remoteDigest)
        #expect(await remote.callCount() == 1)
        #expect(await store.saveCallCount() == 1)
        #expect(await store.savedDigest() == StoredDigest(digest: remoteDigest, savedAt: currentDate))
    }

    @Test
    func staleCacheLoadsAndSavesRemoteDigest() async throws {
        let cachedDigest = makeDigest(title: "Cached")
        let remoteDigest = makeDigest(title: "Remote")
        let store = LocalDigestStoreSpy(
            loadBehavior: .stored(StoredDigest(digest: cachedDigest, savedAt: previousDate))
        )
        let remote = DigestRepositoryStub(result: .success(remoteDigest))
        let repository = makeRepository(localStore: store, remoteRepository: remote)

        let digest = try await repository.fetchDailyDigest()

        #expect(digest == remoteDigest)
        #expect(await remote.callCount() == 1)
        #expect(await store.saveCallCount() == 1)
    }

    @Test
    func staleCacheIsReturnedWhenRemoteFails() async throws {
        let cachedDigest = makeDigest(title: "Cached")
        let store = LocalDigestStoreSpy(
            loadBehavior: .stored(StoredDigest(digest: cachedDigest, savedAt: previousDate))
        )
        let remote = DigestRepositoryStub(result: .failure(.remoteUnavailable))
        let repository = makeRepository(localStore: store, remoteRepository: remote)

        let digest = try await repository.fetchDailyDigest()

        #expect(digest == cachedDigest)
        #expect(await remote.callCount() == 1)
        #expect(await store.saveCallCount() == 0)
    }

    @Test
    func remoteErrorIsPropagatedWhenCacheIsMissing() async {
        let store = LocalDigestStoreSpy(loadBehavior: .missing)
        let remote = DigestRepositoryStub(result: .failure(.remoteUnavailable))
        let repository = makeRepository(localStore: store, remoteRepository: remote)

        await #expect(throws: TestError.remoteUnavailable) {
            try await repository.fetchDailyDigest()
        }
    }

    @Test
    func cancellationDoesNotFallBackToStaleCache() async {
        let cachedDigest = makeDigest(title: "Cached")
        let store = LocalDigestStoreSpy(
            loadBehavior: .stored(StoredDigest(digest: cachedDigest, savedAt: previousDate))
        )
        let repository = makeRepository(
            localStore: store,
            remoteRepository: CancellationDigestRepository()
        )

        await #expect(throws: CancellationError.self) {
            try await repository.fetchDailyDigest()
        }
    }

    @Test
    func remoteDigestIsReturnedWhenSavingCacheFails() async throws {
        let remoteDigest = makeDigest(title: "Remote")
        let store = LocalDigestStoreSpy(
            loadBehavior: .missing,
            saveBehavior: .fail
        )
        let remote = DigestRepositoryStub(result: .success(remoteDigest))
        let repository = makeRepository(localStore: store, remoteRepository: remote)

        let digest = try await repository.fetchDailyDigest()

        #expect(digest == remoteDigest)
        #expect(await remote.callCount() == 1)
        #expect(await store.saveCallCount() == 1)
    }

    @Test
    func remoteLoadsWhenReadingCacheFails() async throws {
        let remoteDigest = makeDigest(title: "Remote")
        let store = LocalDigestStoreSpy(loadBehavior: .fail)
        let remote = DigestRepositoryStub(result: .success(remoteDigest))
        let repository = makeRepository(localStore: store, remoteRepository: remote)

        let digest = try await repository.fetchDailyDigest()

        #expect(digest == remoteDigest)
        #expect(await remote.callCount() == 1)
        #expect(await store.saveCallCount() == 1)
    }

    @Test
    func remoteErrorIsPropagatedWhenReadingCacheFails() async {
        let store = LocalDigestStoreSpy(loadBehavior: .fail)
        let remote = DigestRepositoryStub(result: .failure(.remoteUnavailable))
        let repository = makeRepository(localStore: store, remoteRepository: remote)

        await #expect(throws: TestError.remoteUnavailable) {
            try await repository.fetchDailyDigest()
        }
    }

    private func makeRepository(
        localStore: any LocalDigestStore,
        remoteRepository: any DigestRepository
    ) -> OfflineFirstDigestRepository {
        OfflineFirstDigestRepository(
            localStore: localStore,
            remoteRepository: remoteRepository,
            freshnessPolicy: DigestFreshnessPolicy(calendar: calendar),
            currentDate: { currentDate }
        )
    }

    private func makeDigest(title: String) -> DailyDigest {
        DailyDigest(
            date: currentDate,
            items: [
                DigestItem(
                    id: UUID(uuidString: "64E424CC-BA16-44EA-90B0-3BFD9B3A063D")!,
                    title: title,
                    summary: "A concise summary.",
                    whyItMatters: "It informs an important decision.",
                    sourceName: "Test Journal",
                    sourceURL: URL(string: "https://example.com/article")!,
                    publishedAt: currentDate
                )
            ]
        )
    }

    private var calendar: Calendar {
        Calendar(identifier: .gregorian)
    }

    private var currentDate: Date {
        Date(timeIntervalSince1970: 1_784_160_000)
    }

    private var previousDate: Date {
        Date(timeIntervalSince1970: 1_784_073_600)
    }
}

private actor LocalDigestStoreSpy: LocalDigestStore {
    enum LoadBehavior: Sendable {
        case missing
        case stored(StoredDigest)
        case fail
    }

    enum SaveBehavior: Sendable {
        case succeed
        case fail
    }

    private let loadBehavior: LoadBehavior
    private let saveBehavior: SaveBehavior
    private var loadCalls = 0
    private var saveCalls = 0
    private var lastSavedDigest: StoredDigest?

    init(loadBehavior: LoadBehavior, saveBehavior: SaveBehavior = .succeed) {
        self.loadBehavior = loadBehavior
        self.saveBehavior = saveBehavior
    }

    func load() throws -> StoredDigest? {
        loadCalls += 1

        switch loadBehavior {
        case .missing:
            return nil
        case .stored(let digest):
            return digest
        case .fail:
            throw TestError.cacheUnavailable
        }
    }

    func save(_ storedDigest: StoredDigest) throws {
        saveCalls += 1

        guard saveBehavior == .succeed else {
            throw TestError.cacheUnavailable
        }

        lastSavedDigest = storedDigest
    }

    func loadCallCount() -> Int {
        loadCalls
    }

    func saveCallCount() -> Int {
        saveCalls
    }

    func savedDigest() -> StoredDigest? {
        lastSavedDigest
    }
}

private actor DigestRepositoryStub: DigestRepository {
    let result: Result<DailyDigest, TestError>
    private var calls = 0

    init(result: Result<DailyDigest, TestError>) {
        self.result = result
    }

    func fetchDailyDigest() async throws -> DailyDigest {
        calls += 1
        return try result.get()
    }

    func callCount() -> Int {
        calls
    }
}

private struct CancellationDigestRepository: DigestRepository {
    func fetchDailyDigest() async throws -> DailyDigest {
        throw CancellationError()
    }
}

private enum TestError: Error, Equatable, Sendable {
    case cacheUnavailable
    case remoteUnavailable
}
