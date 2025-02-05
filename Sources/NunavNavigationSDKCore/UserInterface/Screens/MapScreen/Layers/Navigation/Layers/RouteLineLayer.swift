import Foundation
import Mapbox
import MultiplatformNavigation

class RouteLineLayer: MGLLineStyleLayer {
    // MARK: Nested Types

    enum Constants {
        static let fillColorKey = RouteFeatureCreatorCompanion.shared.FILL_COLOR
    }

    // MARK: Lifecycle

    init(factor: Double = 1, identifier: String, source: MGLSource) {
        super.init(identifier: identifier, source: source)
        lineWidth = NSExpression(
            forMGLInterpolating: .zoomLevelVariable,
            curveType: .linear,
            parameters: nil,
            stops: NSExpression(forConstantValue: [
                1: 1 * factor,
                16: 10 * factor,
                20: 16 * factor
            ])
        )
        lineColor = NSExpression(forKeyPath: Constants.fillColorKey)
        lineCap = NSExpression(forConstantValue: "round")
        lineJoin = NSExpression(forConstantValue: "round")
    }
}
