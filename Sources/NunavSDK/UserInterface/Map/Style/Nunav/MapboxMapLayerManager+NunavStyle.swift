import Foundation
import GMMapUtility
import Mapbox

public extension MapboxMapLayerManager {
    func addLineLayer(layer: MGLStyleLayer) throws {
        try add(layer: layer, belowLayerWith: "reference-line-layer")
    }

    func addSymbolLayer(layer: MGLStyleLayer) throws {
        try add(layer: layer, belowLayerWith: "reference-symbol-layer")
    }

    func addRouteLineLayer(layer: MGLStyleLayer) throws {
        try add(layer: layer, belowLayerWith: "reference-route-line-layer")
    }

    func addRouteSymbolLayer(layer: MGLStyleLayer) throws {
        try add(layer: layer, belowLayerWith: "reference-route-symbol-layer")
    }
}
