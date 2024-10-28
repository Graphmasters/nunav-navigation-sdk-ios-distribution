import Foundation
import PackagePlugin

@main
struct SwiftGenPluginAssets: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        let swiftgenConfig = try SwiftGenCommandConfig.make(for: context, target: target)
        try FileManager.default.createDirectory(
            atPath: swiftgenConfig.outputFilesPath.string,
            withIntermediateDirectories: true
        )
        try swiftgenConfig.configFileContents.write(toFile: swiftgenConfig.configPath.string, atomically: true, encoding: .utf8)
        return [.swiftgenCommand(for: swiftgenConfig)]
    }
}

struct SwiftGenCommandConfig {
    var toolPath: Path
    var configPath: Path
    var configFileContents: String
    var outputFilesPath: Path
    var environment: [String: CustomStringConvertible]
}

extension SwiftGenCommandConfig {
    // MARK: Lifecycle

    init(toolPath: Path, inputFilesPath: Path, outputFilesPath: Path, target: Target) {
        self.init(
            toolPath: toolPath,
            configPath: outputFilesPath.appending("swiftgen-assets.yml"),
            configFileContents: Self.configFileContents(target: target),
            outputFilesPath: outputFilesPath,
            environment: [
                "INPUT_DIR": inputFilesPath,
                "OUTPUT_DIR": outputFilesPath
            ]
        )
    }

    // MARK: Static Functions

    static func make(for context: PluginContext, target: Target) throws -> Self {
        try .init(
            toolPath: context.tool(named: "swiftgen").path,
            inputFilesPath: target.directory,
            outputFilesPath: context.pluginWorkDirectory.appending("Generated").appending(target.name),
            target: target
        )
    }

    static func configFileContents(target: Target) -> String {
        return """
        input_dir: ${INPUT_DIR}
        output_dir: ${OUTPUT_DIR}
        xcassets:
          inputs: ./Resources/Media.xcassets
          outputs:
            templateName: swift5
            output: Assets.swift
            params:
              publicAccess: \(target.name.hasPrefix("Shared") ? "true" : "false")
              enumName: \(target.name.hasPrefix("Shared") ? "SharedResources" : "Asset")
        """
    }
}

extension Command {
    static func swiftgenCommand(for swiftgen: SwiftGenCommandConfig) -> Command {
        .prebuildCommand(
            displayName: "Running SwiftGen",
            executable: swiftgen.toolPath,
            arguments: ["config", "run", "--verbose", "--config", swiftgen.configPath],
            environment: swiftgen.environment,
            outputFilesDirectory: swiftgen.outputFilesPath
        )
    }
}
