@MainActor
public protocol AnalyticsTracking {
    func track(_ event: AnalyticsEvent)
}

@MainActor
public struct NoOpAnalyticsTracker: AnalyticsTracking {
    public init() {}

    public func track(_ event: AnalyticsEvent) {
    }
}
