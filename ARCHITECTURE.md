# Architecture

## Principles

- Build vertical features incrementally.
- Keep domain models independent from SwiftUI and persistence.
- Hide data sources behind protocols.
- Prefer native Apple frameworks.
- Use Swift strict concurrency.
- Avoid abstractions without a concrete need.

## Initial data flow

SwiftUI View
    ↓
DigestFeatureModel
    ↓
DigestRepository
    ↓
BundledDigestRepository
    ↓
daily_digest.json

## Initial modules

- App: composition root and application entry point
- Domain: entities and repository protocols
- Data: concrete repository implementations
- Features: presentation logic and SwiftUI
- Resources: bundled fixtures

## Future evolution

BundledDigestRepository
    ↓
RemoteDigestRepository
    ↓
CachingDigestRepository
    ↓
SwiftData
