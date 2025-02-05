import Mapbox

final class RouteCircleEndpointsLayer: MGLCircleStyleLayer {
    // MARK: Nested Types

    enum Constants {
        public static let circleColor = UIColor(hex: "#ffffff")
        public static let circleStrokeColor = UIColor(hex: "#606060")
    }

    // MARK: Lifecycle

    override init(identifier: String, source: MGLSource) {
        super.init(identifier: identifier, source: source)
        circlePitchAlignment = NSExpression(forConstantValue: "map")
        circleColor = NSExpression(forConstantValue: Constants.circleColor)
        circleStrokeColor = NSExpression(forConstantValue: Constants.circleStrokeColor)
        circleStrokeWidth = NSExpression(
            forMGLInterpolating: .zoomLevelVariable,
            curveType: .linear,
            parameters: nil,
            stops: NSExpression(forConstantValue: [10: 1.5, 16: 2.0, 20: 3.0])
        )
        circleRadius = NSExpression(
            forMGLInterpolating: .zoomLevelVariable,
            curveType: .linear,
            parameters: nil,
            stops: NSExpression(forConstantValue: [10: 5, 16: 8, 20: 17])
        )
    }
}
