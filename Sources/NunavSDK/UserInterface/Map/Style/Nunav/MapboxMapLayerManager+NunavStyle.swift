import Foundation
import GMMapUtility
import Mapbox

extension MapboxMapLayerManager {
    public func addLineLayer(layer: MGLStyleLayer) throws {
        try add(layer: layer, belowLayerWith: "reference-line-layer")
    }

    public func addSymbolLayer(layer: MGLStyleLayer) throws {
        try add(layer: layer, belowLayerWith: "reference-symbol-layer")
    }

    public func addRouteLineLayer(layer: MGLStyleLayer) throws {
        try add(layer: layer, belowLayerWith: "reference-route-line-layer")
    }

    public func addRouteSymbolLayer(layer: MGLStyleLayer) throws {
        try add(layer: layer, belowLayerWith: "reference-route-symbol-layer")
    }
}
