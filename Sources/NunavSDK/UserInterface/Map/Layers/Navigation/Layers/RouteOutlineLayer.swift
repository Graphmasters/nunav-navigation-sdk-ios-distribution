import Foundation
import Mapbox
import NunavSDKMultiplatform

final class RouteOutlineLayer: MGLLineStyleLayer {
    // MARK: Nested Types

    enum Constants {
        static let outlineColorKey = RouteFeatureCreatorCompanion.shared.OUTLINE_COLOR
    }

    // MARK: Lifecycle

    override init(identifier: String, source: MGLSource) {
        super.init(identifier: identifier, source: source)
        lineWidth = NSExpression(forMGLInterpolating: .zoomLevelVariable,
                                 curveType: .linear,
                                 parameters: nil,
                                 stops: NSExpression(forConstantValue: [
                                     1: 2.5,
                                     16: 12.5,
                                     20: 19
                                 ]))
        lineColor = NSExpression(forKeyPath: Constants.outlineColorKey)
        lineCap = NSExpression(forConstantValue: "round")
        lineJoin = NSExpression(forConstantValue: "round")
    }
}
