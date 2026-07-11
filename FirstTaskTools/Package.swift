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
        .package(url: "https://github.com/realm/SwiftLint.git", exact: "0.65.0"),
        .package(url: "https://github.com/mono0926/LicensePlist.git", exact: "3.27.9"),
        // for Crashlytics/upload-symbols binary
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", exact: "12.16.0"),

    ],
    targets: [
        .target(
            name: "FirstTaskTools",
            dependencies: []
        )
    ]
)
