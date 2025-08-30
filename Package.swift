// swift-tools-version: 6.2

import PackageDescription

let swiftSettings: [SwiftSetting] = [
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("MemberImportVisibility"),
]

let package = Package(
    name: "DevColorExtraction",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
        .tvOS(.v18),
    ],
    products: [
        .library(
            name: "DevColorExtraction",
            targets: ["DevColorExtraction"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-numerics", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "DevColorExtraction",
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "DevColorExtractionTests",
            dependencies: [
                "DevColorExtraction",
                .product(name: "RealModule", package: "swift-numerics"),
            ],
            resources: [
                .process("Resources")
            ],
            swiftSettings: swiftSettings
        ),
    ]
)
