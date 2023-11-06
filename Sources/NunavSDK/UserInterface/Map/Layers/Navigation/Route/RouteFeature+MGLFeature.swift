import Foundation
import Mapbox
import NunavSDKMultiplatform

extension Array where Element: RouteFeatureCreatorRouteFeature {
    var mglFeature: MGLShapeCollectionFeature {
        let features = map { (feature: RouteFeatureCreatorRouteFeature) -> MGLPolylineFeature in
            let mglFeature = MGLPolylineFeature(coordinates: feature.polyline.map { $0.clLocationCoordinate2D },
                                                count: UInt(feature.polyline.count))
            mglFeature.attributes = feature.properties
            return mglFeature
        }
        return MGLShapeCollectionFeature(shapes: features)
    }
}
