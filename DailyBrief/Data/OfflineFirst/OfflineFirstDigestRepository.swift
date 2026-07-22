import Foundation

nonisolated struct OfflineFirstDigestRepository: DigestRepository {
    private let localStore: any LocalDigestStore
    private let remoteRepository: any DigestRepository
    private let freshnessPolicy: DigestFreshnessPolicy
    private let currentDate: @Sendable () -> Date

    init(
        localStore: any LocalDigestStore,
        remoteRepository: any DigestRepository,
        freshnessPolicy: DigestFreshnessPolicy,
        currentDate: @escaping @Sendable () -> Date
    ) {
        self.localStore = localStore
        self.remoteRepository = remoteRepository
        self.freshnessPolicy = freshnessPolicy
        self.currentDate = currentDate
    }

    @concurrent
    func fetchDailyDigest() async throws -> DailyDigest {
        let requestDate = currentDate()
        let cachedDigest: StoredDigest?

        do {
            cachedDigest = try await localStore.load()
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            cachedDigest = nil
        }

        if let cachedDigest, freshnessPolicy.isFresh(cachedDigest, at: requestDate) {
            return cachedDigest.digest
        }

        do {
            let remoteDigest = try await remoteRepository.fetchDailyDigest()

            do {
                try await localStore.save(
                    StoredDigest(digest: remoteDigest, savedAt: requestDate)
                )
            } catch {
            }

            return remoteDigest
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            if let cachedDigest {
                return cachedDigest.digest
            }

            throw error
        }
    }
}
