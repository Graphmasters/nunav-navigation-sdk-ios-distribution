// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import Foundation

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
    dependencies: .standard(
        [
        .package(url: "https://github.com/Graphmasters/ios-core-utility-distribution", exact: "1.2.10"),
        .package(url: "https://github.com/Graphmasters/ios-map-utility-distribution", exact: "1.3.0"),
        .package(url: "https://github.com/Graphmasters/nunav-ios-design-system-distribution", exact: "1.0.34"),
        .package(url: "https://github.com/Graphmasters/multiplatform-navigation-ios-distribution", exact: "2.1.19"),
        .package(url: "https://github.com/rhodgkins/SwiftHTTPStatusCodes", from: "3.3.2")
        ]
    ),
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
            ],
            plugins: .standard()
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
                ),
                .product(
                    name: "HTTPStatusCodes",
                    package: "SwiftHTTPStatusCodes"
                )
            ],
            plugins: .standard()
        )
    ]
)

// MARK: - Dependencies

extension Array where Element == Package.Dependency {
    /// Applying all standard dependencies based  on the build environment
    static let standard = Self.standard([])

    /// Applying all standard dependencies based  on the build environment
    ///
    /// - Parameters: All dependencies which should always be applied.
    ///
    /// - note: This is primarily used to disable SwiftLint resolution in CI runs.
    static func standard(_ additionalDependencies: [Package.Dependency]) -> [Package.Dependency] {
        guard !runningInCI else {
            return additionalDependencies
        }
        return [
            .package(url: "https://github.com/realm/SwiftLint.git", from: "0.55.1"),
            .package(url: "https://github.com/nicklockwood/SwiftFormat", from: "0.54.3")
        ] + additionalDependencies
    }
}

// MARK: - Plugins

extension Target.PluginUsage {
    static let swiftLint: Target.PluginUsage = .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint")
}

extension Array where Element == Target.PluginUsage {
    /// Applying all standard plugins based on the build environment
    static let standard = Self.standard()

    /// Applying all standard plugins based on the build environment
    ///
    /// - Parameters: All plugins which should always be applied.
    ///
    /// - note: This is primarily used to disable SwiftLint in CI runs.
    /// - warning: Pay attention to not add plugins twice (via ``additionalPlugins`` and in the standard implementation).
    static func standard(_ additionalPlugins: [Target.PluginUsage] = []) -> [Target.PluginUsage] {
        guard !runningInCI else {
            return additionalPlugins
        }
        return [
            /// The current version has a bug where remote configurations are not loaded when applying the plugin.
            /// You have to run `swiftlint .` manually from the terminal every time the remote config has changed.
            .swiftLint
        ] + additionalPlugins
    }
}

// MARK: - Helpers

/// Returns whether the current build runs in the CI.
var runningInCI: Bool {
    ProcessInfo.processInfo.environment["RUNNING_IN_CI"] != nil
}
