import Foundation
import Mapbox
import NunavSDKMultiplatform

final class RouteLineLayer: MGLLineStyleLayer {
    enum Constants {
        static let fillColorKey = RouteFeatureCreatorCompanion.shared.FILL_COLOR
    }

    override init(identifier: String, source: MGLSource) {
        super.init(identifier: identifier, source: source)
        lineWidth = NSExpression(
            forMGLInterpolating: .zoomLevelVariable,
            curveType: .linear,
            parameters: nil,
            stops: NSExpression(forConstantValue: [
                1: 1,
                16: 10,
                20: 16
            ])
        )
        lineColor = NSExpression(forKeyPath: Constants.fillColorKey)
        lineCap = NSExpression(forConstantValue: "round")
        lineJoin = NSExpression(forConstantValue: "round")
    }
}
