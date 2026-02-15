// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SocialEffects",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "social-effects",
            targets: ["SocialEffects"]
        ),
    ],
    targets: [
        .executableTarget(
            name: "SocialEffects",
            dependencies: [],
            linkerSettings: [
                // Link to Shotcut's MLT libraries with full paths
                .unsafeFlags([
                    "-Xlinker", "/Applications/Shotcut.app/Contents/Frameworks/libmlt-7.7.dylib",
                    "-Xlinker", "/Applications/Shotcut.app/Contents/Frameworks/libmlt++-7.7.dylib"
                ])
            ]
        ),
    ]
)
