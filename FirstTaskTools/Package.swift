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
        .package(url: "https://github.com/realm/SwiftLint.git", exact: "0.59.1"),
        .package(url: "https://github.com/mono0926/LicensePlist.git", exact: "3.27.2"),
    ],
    targets: [
        .target(
            name: "FirstTaskTools",
            dependencies: []
        )
    ]
)
