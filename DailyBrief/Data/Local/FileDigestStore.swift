import Foundation

nonisolated enum FileDigestStoreError: Error, Equatable, Sendable {
    case unreadableCache
    case invalidCache
    case unwritableCache
}

actor FileDigestStore: LocalDigestStore {
    private let fileURL: URL

    init(fileURL: URL) {
        self.fileURL = fileURL
    }

    func load() throws -> StoredDigest? {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }

        let data: Data
        do {
            data = try Data(contentsOf: fileURL)
        } catch {
            throw FileDigestStoreError.unreadableCache
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            return try decoder.decode(StoredDigest.self, from: data)
        } catch {
            throw FileDigestStoreError.invalidCache
        }
    }

    func save(_ storedDigest: StoredDigest) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let data: Data
        do {
            data = try encoder.encode(storedDigest)
        } catch {
            throw FileDigestStoreError.unwritableCache
        }

        do {
            try data.write(to: fileURL, options: .atomic)
        } catch {
            throw FileDigestStoreError.unwritableCache
        }
    }
}
