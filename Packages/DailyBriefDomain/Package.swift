// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "DailyBriefDomain",
    platforms: [.iOS(.v26)],
    products: [
        .library(name: "DailyBriefDomain", targets: ["DailyBriefDomain"])
    ],
    targets: [
        .target(name: "DailyBriefDomain"),
        .testTarget(name: "DailyBriefDomainTests", dependencies: ["DailyBriefDomain"])
    ]
)
