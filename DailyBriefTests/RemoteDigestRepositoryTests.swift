import Foundation
import Testing
@testable import DailyBrief

struct RemoteDigestRepositoryTests {
    @Test
    func successfulResponseMapsToDomainDigest() async throws {
        let repository = try makeRepository(
            result: .success(HTTPClientResponse(data: validPayload, statusCode: 200))
        )

        let digest = try await repository.fetchDailyDigest()

        #expect(digest.items.count == 1)
        #expect(digest.items.first?.title == "A useful article")
        #expect(digest.items.first?.sourceURL.absoluteString == "https://example.com/article")
    }

    @Test
    func transportErrorIsMapped() async throws {
        let repository = try makeRepository(result: .failure(TestError.unavailable))

        do {
            _ = try await repository.fetchDailyDigest()
            Issue.record("Expected a transport error")
        } catch RemoteDigestRepositoryError.transport(let underlyingError) {
            #expect(underlyingError is TestError)
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test(arguments: [404, 500])
    func invalidStatusCodeIsRejected(statusCode: Int) async throws {
        let repository = try makeRepository(
            result: .success(HTTPClientResponse(data: validPayload, statusCode: statusCode))
        )

        do {
            _ = try await repository.fetchDailyDigest()
            Issue.record("Expected an invalid status-code error")
        } catch RemoteDigestRepositoryError.unacceptableStatusCode(let receivedStatusCode) {
            #expect(receivedStatusCode == statusCode)
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test
    func malformedJSONIsMappedToInvalidPayload() async throws {
        let repository = try makeRepository(
            result: .success(
                HTTPClientResponse(data: Data("not json".utf8), statusCode: 200)
            )
        )

        do {
            _ = try await repository.fetchDailyDigest()
            Issue.record("Expected an invalid payload error")
        } catch RemoteDigestRepositoryError.invalidPayload {
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test
    func cancellationIsPreserved() async throws {
        let repository = try makeRepository(result: .failure(CancellationError()))

        await #expect(throws: CancellationError.self) {
            try await repository.fetchDailyDigest()
        }
    }

    private func makeRepository(
        result: Result<HTTPClientResponse, any Error>
    ) throws -> RemoteDigestRepository {
        let endpoint = try #require(URL(string: "https://example.com/digest"))
        return RemoteDigestRepository(
            client: StubHTTPClient(result: result),
            endpoint: endpoint
        )
    }

    private var validPayload: Data {
        Data(
            #"""
            {
              "date": "2026-07-21T00:00:00Z",
              "items": [
                {
                  "id": "64E424CC-BA16-44EA-90B0-3BFD9B3A063D",
                  "title": "A useful article",
                  "summary": "A concise summary.",
                  "whyItMatters": "It informs an important decision.",
                  "sourceName": "Test Journal",
                  "sourceURL": "https://example.com/article",
                  "publishedAt": "2026-07-21T08:00:00Z"
                }
              ]
            }
            """#.utf8
        )
    }
}

private nonisolated struct StubHTTPClient: HTTPClient {
    let result: Result<HTTPClientResponse, any Error>

    func data(for request: URLRequest) async throws -> HTTPClientResponse {
        try result.get()
    }
}

private nonisolated enum TestError: Error {
    case unavailable
}
