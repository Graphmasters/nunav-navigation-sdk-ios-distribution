// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "nunav-navigation-sdk",
    defaultLocalization: "en",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "NunavNavigationSDK",
            targets: ["NunavNavigationSDK"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/Graphmasters/ios-core-utility-distribution", from: "1.2.9"),
        .package(url: "https://github.com/Graphmasters/ios-map-utility-distribution", from: "1.3.0"),
        .package(url: "https://github.com/Graphmasters/nunav-ios-design-system-distribution", from: "1.0.34"),
        .package(url: "https://github.com/Graphmasters/multiplatform-navigation-ios-distribution", from: "2.1.6")
    ],
    targets: [
        .target(
            name: "NunavNavigationSDK",
            dependencies: [
                "NunavNavigationSDKCore",
                .product(
                    name: "MultiplatformNavigation",
                    package: "multiplatform-navigation-ios-distribution"
                )
            ],
            resources: [
                .process("Resources/PrivacyInfo.xcprivacy"),
            ]
        ),
        .target(
            name: "NunavNavigationSDKCore",
            dependencies: [
                .product(
                    name: "GMCoreUtility",
                    package: "ios-core-utility-distribution"
                ),
                .product(
                    name: "GMMapUtility",
                    package: "ios-map-utility-distribution"
                ),
                .product(
                    name: "NunavDesignSystem",
                    package: "nunav-ios-design-system-distribution"
                )
            ]
        )
    ]
)
