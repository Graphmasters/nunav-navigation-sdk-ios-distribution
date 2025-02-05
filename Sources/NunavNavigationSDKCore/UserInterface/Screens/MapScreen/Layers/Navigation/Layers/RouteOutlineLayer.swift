import Foundation
import Mapbox
import MultiplatformNavigation

class RouteOutlineLayer: RouteLineLayer {
    // MARK: Nested Types

    enum Constants {
        static let outlineColorKey = RouteFeatureCreatorCompanion.shared.OUTLINE_COLOR
    }

    // MARK: Lifecycle

    init(identifier: String, source: MGLSource) {
        super.init(factor: 1.25, identifier: identifier, source: source)
        lineColor = NSExpression(forKeyPath: Constants.outlineColorKey)
    }
}
