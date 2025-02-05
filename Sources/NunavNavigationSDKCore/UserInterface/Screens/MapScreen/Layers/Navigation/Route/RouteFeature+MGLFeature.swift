import Foundation
import Mapbox
import MultiplatformNavigation

extension Array where Element: RouteFeatureCreatorRouteFeature {
    var mglFeature: MGLShapeCollectionFeature {
        let features = map { (feature: RouteFeatureCreatorRouteFeature) -> MGLPolylineFeature in
            let mglFeature = MGLPolylineFeature(
                coordinates: feature.polyline.map {
                    CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
                },
                count: UInt(feature.polyline.count)
            )
            mglFeature.attributes = feature.properties
            return mglFeature
        }
        return MGLShapeCollectionFeature(shapes: features)
    }
}
