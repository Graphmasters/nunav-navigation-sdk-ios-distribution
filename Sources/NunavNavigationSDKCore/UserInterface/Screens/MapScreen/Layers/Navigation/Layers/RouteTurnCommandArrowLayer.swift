import Mapbox

final class RouteTurnCommandArrowLayer: RouteLineLayer {
    init(identifier: String, source: MGLSource) {
        super.init(factor: 0.75, identifier: identifier, source: source)
        lineColor = NSExpression(forConstantValue: UIColor.white)
    }
}
