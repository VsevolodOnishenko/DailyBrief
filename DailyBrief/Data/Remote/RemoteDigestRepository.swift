import Foundation

nonisolated enum RemoteDigestRepositoryError: Error, Sendable {
    case transport(any Error)
    case unacceptableStatusCode(Int)
    case invalidPayload(any Error)
}

nonisolated struct RemoteDigestRepository: DigestRepository {
    private let client: any HTTPClient
    private let endpoint: URL

    init(client: any HTTPClient, endpoint: URL) {
        self.client = client
        self.endpoint = endpoint
    }

    @concurrent
    func fetchDailyDigest() async throws -> DailyDigest {
        let response: HTTPClientResponse

        do {
            response = try await client.data(for: URLRequest(url: endpoint))
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            throw RemoteDigestRepositoryError.transport(error)
        }

        guard (200..<300).contains(response.statusCode) else {
            throw RemoteDigestRepositoryError.unacceptableStatusCode(response.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            let dto = try decoder.decode(RemoteDailyDigestDTO.self, from: response.data)
            return try dto.domainModel()
        } catch {
            throw RemoteDigestRepositoryError.invalidPayload(error)
        }
    }
}
