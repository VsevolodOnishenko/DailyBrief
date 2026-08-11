@MainActor
protocol AnalyticsTracking {
    func track(_ event: AnalyticsEvent)
}

@MainActor
struct NoOpAnalyticsTracker: AnalyticsTracking {
    func track(_ event: AnalyticsEvent) {
    }
}
