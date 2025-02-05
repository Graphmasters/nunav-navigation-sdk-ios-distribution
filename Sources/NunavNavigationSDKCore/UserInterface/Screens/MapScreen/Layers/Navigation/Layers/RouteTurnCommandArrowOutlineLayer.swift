import Mapbox

final class RouteTurnCommandArrowOutlineLayer: RouteOutlineLayer {
    override init(identifier: String, source: MGLSource) {
        super.init(identifier: identifier, source: source)
        lineColor = NSExpression(forConstantValue: UIColor(hex: "#405A78"))
    }
}
