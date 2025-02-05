import Foundation

struct CameraConfiguration {
    // MARK: Nested Types

    enum Constants {
        static let defaultZoomLevelOffset: Double = 0
        static let defaultTiltFactor: Double = 1
    }

    enum Perspective: Int, CaseIterable, Codable {
        case threeDimensional
        case twoDimensional
        case twoDimensionalNorth
    }

    // MARK: Properties

    let zoomLevelOffset: Double
    let tiltFactor: Double
    let perspective: Perspective

    // MARK: Lifecycle

    init(
        zoomLevelOffset: Double = Constants.defaultZoomLevelOffset,
        tiltFactor: Double = Constants.defaultTiltFactor,
        perspective: Perspective = .threeDimensional
    ) {
        self.zoomLevelOffset = zoomLevelOffset
        self.tiltFactor = tiltFactor
        self.perspective = perspective
    }
}
