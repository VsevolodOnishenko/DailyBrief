import Foundation
import DailyBriefDomain

nonisolated struct RemoteDailyDigestDTO: Decodable, Sendable {
    let date: Date
    let items: [RemoteDigestItemDTO]

    func domainModel() throws -> DailyDigest {
        DailyDigest(
            date: date,
            items: try items.map { try $0.domainModel() }
        )
    }
}

nonisolated struct RemoteDigestItemDTO: Decodable, Sendable {
    let id: UUID
    let title: String
    let summary: String
    let whyItMatters: String
    let sourceName: String
    let sourceURL: URL
    let publishedAt: Date

    func domainModel() throws -> DigestItem {
        guard
            let scheme = sourceURL.scheme?.lowercased(),
            ["http", "https"].contains(scheme),
            sourceURL.host != nil
        else {
            throw RemoteDigestMappingError.unsupportedSourceURL(sourceURL)
        }

        return DigestItem(
            id: id,
            title: title,
            summary: summary,
            whyItMatters: whyItMatters,
            sourceName: sourceName,
            sourceURL: sourceURL,
            publishedAt: publishedAt
        )
    }
}

nonisolated enum RemoteDigestMappingError: Error, Equatable, Sendable {
    case unsupportedSourceURL(URL)
}
