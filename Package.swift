// swift-tools-version: 6.2

import PackageDescription

extension String {
    static let iso8601: Self = "ISO 8601"
}

extension Target.Dependency {
    static var iso8601: Self { .target(name: .iso8601) }
    static var standards: Self { .product(name: "Standard Library Extensions", package: "swift-standard-library-extensions") }
    static var time: Self {
        .product(
            name: "Time Primitives",
            package: "swift-time-primitives"
        )
    }
    static var incits_4_1986: Self { .product(name: "ASCII", package: "swift-ascii") }
    static var standardsTestSupport: Self { .product(name: "Test Primitives", package: "swift-test-primitives") }
}

let package = Package(
    name: "swift-iso-8601",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        .library(name: .iso8601, targets: [.iso8601]),
    ],
    dependencies: [
        .package(path: "../../swift-primitives/swift-standard-library-extensions"),
        .package(path: "../../swift-primitives/swift-time-primitives"),
        .package(path: "../../swift-primitives/swift-test-primitives"),
        .package(path: "../../swift-foundations/swift-ascii"),
    ],
    targets: [
        .target(
            name: .iso8601,
            dependencies: [
                .standards,
                .time,
                .incits_4_1986
            ]
        ),
        .testTarget(
            name: .iso8601.tests,
            dependencies: [
                .iso8601,
                .time,  // Needed for Time.Error in test expectations
                .incits_4_1986,
                .standardsTestSupport
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

extension String {
    var tests: Self { self + " Tests" }
    var foundation: Self { self + " Foundation" }
}

for target in package.targets where ![.system, .binary, .plugin].contains(target.type) {
    let existing = target.swiftSettings ?? []
    target.swiftSettings = existing + [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility")
    ]
}
