import Foundation
import DailyBriefDomain

nonisolated struct BundledDigestRepository: DigestRepository {
    nonisolated enum RepositoryError: Error, Equatable, Sendable {
        case resourceNotFound(String)
        case unreadableResource
        case invalidDigest
    }

    private let bundle: Bundle
    private let resourceName: String

    init(bundle: Bundle = .main, resourceName: String = "daily_digest") {
        self.bundle = bundle
        self.resourceName = resourceName
    }

    @concurrent
    func fetchDailyDigest() async throws -> DailyDigest {
        guard let url = bundle.url(forResource: resourceName, withExtension: "json") else {
            throw RepositoryError.resourceNotFound(resourceName)
        }

        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw RepositoryError.unreadableResource
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            return try decoder.decode(DailyDigest.self, from: data)
        } catch {
            throw RepositoryError.invalidDigest
        }
    }
}
