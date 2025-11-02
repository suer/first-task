// swift-tools-version: 6.1.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FirstTaskDependencies",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "FirstTaskDependencies",
            targets: ["FirstTaskDependencies"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", exact: "12.5.0"),
        .package(url: "https://github.com/firebase/FirebaseUI-iOS.git", exact: "15.1.0"),
        .package(url: "https://github.com/mono0926/LicensePlist.git", exact: "3.27.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "FirstTaskDependencies",
            dependencies: [
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAuthUI", package: "FirebaseUI-iOS"),
                .product(name: "FirebaseGoogleAuthUI", package: "FirebaseUI-iOS")
            ]
        )
    ]
)
