import Foundation

nonisolated enum URLSessionHTTPClientError: Error, Equatable, Sendable {
    case nonHTTPResponse
}

nonisolated struct URLSessionHTTPClient: HTTPClient {
    private let session: URLSession

    init(session: URLSession) {
        self.session = session
    }

    func data(for request: URLRequest) async throws -> HTTPClientResponse {
        let (data, response) = try await session.data(for: request)

        guard let response = response as? HTTPURLResponse else {
            throw URLSessionHTTPClientError.nonHTTPResponse
        }

        return HTTPClientResponse(data: data, statusCode: response.statusCode)
    }
}
