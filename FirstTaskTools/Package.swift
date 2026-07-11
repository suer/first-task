// swift-tools-version: 6.1.2
import PackageDescription

let package = Package(
    name: "FirstTaskTools",
    platforms: [
        .macOS(.v10_14)
    ],
    products: [
        .library(
            name: "FirstTaskTools",
            targets: ["FirstTaskTools"]
        )
    ],
    dependencies: [
        // for Crashlytics/upload-symbols binary
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", exact: "12.16.0")

    ],
    targets: [
        .target(
            name: "FirstTaskTools",
            dependencies: []
        )
    ]
)
