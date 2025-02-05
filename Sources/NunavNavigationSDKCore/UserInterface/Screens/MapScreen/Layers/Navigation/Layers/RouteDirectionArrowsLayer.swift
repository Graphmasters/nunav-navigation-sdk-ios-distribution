import Foundation
import Mapbox
import MultiplatformNavigation

final class RouteDirectionArrowsLayer: MGLSymbolStyleLayer {
    override init(identifier: String, source: MGLSource) {
        super.init(identifier: identifier, source: source)
        symbolPlacement = NSExpression(forConstantValue: "line")
        symbolSpacing = NSExpression(forConstantValue: 200)
        symbolAvoidsEdges = NSExpression(forConstantValue: true)
        iconAllowsOverlap = NSExpression(forConstantValue: true)
        iconIgnoresPlacement = NSExpression(forConstantValue: false)
        iconPadding = NSExpression(forConstantValue: 2)
        iconScale = NSExpression(
            forMGLInterpolating: .zoomLevelVariable,
            curveType: .linear, parameters: nil, stops: NSExpression(forConstantValue: [
                9.9: 0.0,
                10.0: 0.5,
                17.0: 1.0
            ])
        )

        iconRotationAlignment = NSExpression(forConstantValue: MGLIconRotationAlignment.map.rawValue)
        iconImageName = NSExpression(forConstantValue: "direction-arrow")
        text = NSExpression(forConstantValue: "")
    }
}
