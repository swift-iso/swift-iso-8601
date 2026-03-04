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
        .visionOS(.v26)
    ],
    products: [
        .library(name: "ISO 8601", targets: ["ISO 8601"])
    ],
    dependencies: [
        .package(path: "../../swift-primitives/swift-standard-library-extensions"),
        .package(path: "../../swift-primitives/swift-time-primitives"),
        .package(path: "../../swift-foundations/swift-ascii"),
        .package(path: "../../swift-primitives/swift-parser-primitives")
    ],
    targets: [
        .target(
            name: "ISO 8601",
            dependencies: [
                .standards,
                .time,
                .incits_4_1986,
                .product(name: "Parser Primitives", package: "swift-parser-primitives"),
                .product(name: "Parser ASCII Integer Primitives", package: "swift-parser-primitives")
            ]
        ),
        .testTarget(
            name: "ISO 8601 Tests",
            dependencies: [
                "ISO 8601",
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

extension String {
    var tests: Self { self + " Tests" }
    var foundation: Self { self + " Foundation" }
}

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableExperimentalFeature("SuppressedAssociatedTypesWithDefaults"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
