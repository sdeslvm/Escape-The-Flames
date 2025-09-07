// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "EscapeTheFlames",
    platforms: [
        .macOS(.v11),
        .iOS(.v16)
    ],
    products: [
        .executable(name: "EscapeTheFlames", targets: ["EscapeTheFlames"])
    ],
    targets: [
        .executableTarget(
            name: "EscapeTheFlames",
            dependencies: [],
            path: "Sources"
        )
    ]
)
