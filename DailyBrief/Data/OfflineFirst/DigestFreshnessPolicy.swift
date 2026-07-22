import Foundation

nonisolated struct DigestFreshnessPolicy: Sendable {
    private let calendar: Calendar

    init(calendar: Calendar) {
        self.calendar = calendar
    }

    func isFresh(_ storedDigest: StoredDigest, at currentDate: Date) -> Bool {
        calendar.isDate(storedDigest.savedAt, inSameDayAs: currentDate)
    }
}
