// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

extension String {
    static let swiftgen = "swiftgen"
    static let nunavSDK = "NunavSDK"
    static let nunavSDKMultiplatform = "NunavSDKMultiplatform"
}

extension Target.Dependency {
    static let gmCoreUtility: Self = .product(name: "GMCoreUtility", package: "ios-core-utility-distribution")
    static let gmMapUtility: Self = .product(name: "GMMapUtility", package: "ios-map-utility-distribution")
    static let nunavDesignSystem: Self = .product(name: "NunavDesignSystem", package: "nunav-ios-design-system-distribution")

    static let swiftgen: Self = .target(name: .swiftgen)

    static let nunavSDKMultiplatform: Self = .target(name: .nunavSDKMultiplatform)
}

extension Target.PluginUsage {
    static let swiftGenAssets: Self = .plugin(
        name: "SwiftGenAssetsPlugin")
    static let swiftGenLocalization: Self = .plugin(
        name: "SwiftGenLocalizationPlugin")
}

extension Target {
    static let nunavSDK: Target = .target(
        name: .nunavSDK,
        dependencies: [
            .nunavSDKMultiplatform,
            .gmCoreUtility,
            .gmMapUtility,
            .nunavDesignSystem
        ],
        resources: [
            .process("Resources/PrivacyInfo.xcprivacy"),
        ],
        plugins: [
            .swiftGenAssets,
            .swiftGenLocalization
        ]
    )

    static let nunavSDKMultiplatform: Target = .binaryTarget(
        name: .nunavSDKMultiplatform,
        url: "https://github.com/Graphmasters/nunav-navigation-sdk-ios-distribution/releases/download/1.0.3/NunavSDKMultiplatform.xcframework.zip",
        checksum: "a7cdaeab80bc70da475aa374f5cc549f9f256d5c174a9609e5c0f06e91053fc4"
    )

    // MARK: - Plugins

    static let swiftgen: Target = .binaryTarget(
        name: .swiftgen,
        url: "https://github.com/nicorichard/SwiftGen/releases/download/6.5.1/swiftgen.artifactbundle.zip",
        checksum: "a8e445b41ac0fd81459e07657ee19445ff6cbeef64eb0b3df51637b85f925da8"
    )

    static let swiftGenAssetsPlugin: Target = .plugin(
        name: "SwiftGenAssetsPlugin",
        capability: .buildTool(),
        dependencies: [.swiftgen]
    )

    static let swiftGenLocalizationPlugin: Target = .plugin(
        name: "SwiftGenLocalizationPlugin",
        capability: .buildTool(),
        dependencies: [.swiftgen]
    )
}

let package = Package(
    name: "nunav-sdk",
    defaultLocalization: "en",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "NunavSDK",
            targets: ["NunavSDK"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/Graphmasters/ios-core-utility-distribution", from: "1.2.2"),
        .package(url: "https://github.com/Graphmasters/ios-map-utility-distribution", from: "1.1.4"),
        .package(url: "https://github.com/Graphmasters/nunav-ios-design-system-distribution", from: "1.0.30")
    ],
    targets: [
        .nunavSDK,
        .nunavSDKMultiplatform,
        .swiftgen,
        .swiftGenAssetsPlugin,
        .swiftGenLocalizationPlugin
    ]
)
