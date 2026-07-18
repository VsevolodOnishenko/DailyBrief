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
    private let repository: any DigestRepository

    init(repository: any DigestRepository) {
        self.repository = repository
    }

    func load() async {
        state = .loading

        do {
            let digest = try await repository.fetchDailyDigest()
            state = digest.items.isEmpty ? .empty : .content(digest)
        } catch {
            state = .failure("Today's digest could not be loaded.")
        }
    }
}
