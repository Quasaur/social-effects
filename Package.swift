// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "social-effects",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
        .package(url: "https://github.com/fal-ai/fal-swift", from: "0.5.3")
    ],
    targets: [
        .executableTarget(
            name: "SocialEffects",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "FalClient", package: "fal-swift")
            ]
            // MLT linker settings removed - using AVFoundation for now
            // Will add back when implementing MLT renderer
        ),
    ]
)
