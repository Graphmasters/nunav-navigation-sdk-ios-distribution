import Foundation

public struct CameraConfiguration {
    // MARK: Nested Types

    public enum Constants {
        public static let defaultZoomLevelOffset: Double = 0
        public static let defaultTiltFactor: Double = 1
    }

    public enum Perspective: Int, CaseIterable, Codable {
        case threeDimensional
        case twoDimensional
        case twoDimensionalNorth
    }

    // MARK: Properties

    public let zoomLevelOffset: Double
    public let tiltFactor: Double
    public let perspective: Perspective

    // MARK: Lifecycle

    public init(
        zoomLevelOffset: Double = Constants.defaultZoomLevelOffset,
        tiltFactor: Double = Constants.defaultTiltFactor,
        perspective: Perspective = .threeDimensional
    ) {
        self.zoomLevelOffset = zoomLevelOffset
        self.tiltFactor = tiltFactor
        self.perspective = perspective
    }
}
