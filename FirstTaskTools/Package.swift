// swift-tools-version: 6.1.2
import PackageDescription

let package = Package(
    name: "FirstTaskTools",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "FirstTaskTools",
            targets: ["FirstTaskTools"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/realm/SwiftLint.git", exact: "0.63.2")
    ],
    targets: [
        .target(
            name: "FirstTaskTools",
            dependencies: []
        )
    ]
)
