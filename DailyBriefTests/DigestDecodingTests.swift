import Foundation
import Testing
@testable import DailyBrief

@MainActor
struct DigestDecodingTests {
    @Test
    func bundledFixtureDecodesFiveArticles() async throws {
        let digest = try await BundledDigestRepository(bundle: .main).fetchDailyDigest()

        #expect(digest.items.count == 5)
        #expect(digest.items.allSatisfy { !$0.title.isEmpty })
        #expect(Set(digest.items.map(\.id)).count == 5)
    }

    @Test
    func missingFixtureReportsResourceName() async {
        let repository = BundledDigestRepository(
            bundle: .main,
            resourceName: "missing_daily_digest"
        )

        await #expect(throws: BundledDigestRepository.RepositoryError.resourceNotFound("missing_daily_digest")) {
            try await repository.fetchDailyDigest()
        }
    }
}
