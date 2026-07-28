import Observation

@MainActor
@Observable
final class DigestFeatureModel {
    enum State: Equatable {
        case idle
        case loading
        case content(DailyDigest)
        case empty
        case failure(String)
    }

    private(set) var state: State = .idle
    private(set) var isRefreshing = false
    private let repository: any DigestRepository
    private var loadTask: Task<Void, Never>?
    private var loadGeneration = 0

    init(repository: any DigestRepository) {
        self.repository = repository
    }

    func load() async {
        await startLoad(isRefresh: false)
    }

    func refresh() async {
        await startLoad(isRefresh: true)
    }

    private func startLoad(isRefresh: Bool) async {
        loadGeneration += 1
        let generation = loadGeneration
        loadTask?.cancel()

        isRefreshing = isRefresh
        if !isRefresh {
            state = .loading
        }

        let repository = repository
        let task = Task { [weak self, repository] in
            do {
                try Task.checkCancellation()
                let digest = try await repository.fetchDailyDigest()
                try Task.checkCancellation()
                self?.completeLoad(digest, generation: generation)
            } catch is CancellationError {
                self?.completeCancellation(generation: generation)
            } catch {
                if Task.isCancelled {
                    self?.completeCancellation(generation: generation)
                } else {
                    self?.completeFailure(generation: generation, isRefresh: isRefresh)
                }
            }
        }

        loadTask = task
        await task.value
    }

    private func completeLoad(_ digest: DailyDigest, generation: Int) {
        guard generation == loadGeneration else { return }

        state = digest.items.isEmpty ? .empty : .content(digest)
        finishLoad(generation: generation)
    }

    private func completeCancellation(generation: Int) {
        guard generation == loadGeneration else { return }

        finishLoad(generation: generation)
    }

    private func completeFailure(generation: Int, isRefresh: Bool) {
        guard generation == loadGeneration else { return }

        if !isRefresh {
            state = .failure("Today's digest could not be loaded.")
        }
        finishLoad(generation: generation)
    }

    private func finishLoad(generation: Int) {
        guard generation == loadGeneration else { return }

        isRefreshing = false
        loadTask = nil
    }
}
