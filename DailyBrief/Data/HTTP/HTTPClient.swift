import Foundation

nonisolated struct HTTPClientResponse: Sendable {
    let data: Data
    let statusCode: Int
}

nonisolated protocol HTTPClient: Sendable {
    func data(for request: URLRequest) async throws -> HTTPClientResponse
}
