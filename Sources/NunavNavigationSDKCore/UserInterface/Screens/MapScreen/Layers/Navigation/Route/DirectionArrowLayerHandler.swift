import GMMapUtility
import Mapbox
import MultiplatformNavigation

final class DirectionArrowLayerHandler: MGLStyleLayersHandler {
    // MARK: Properties

    var waypoints: [Route.Waypoint] = [] {
        didSet {
            DispatchQueue.main.async {
                guard self.waypoints.count > 1 else {
                    try? self.mapLayerManager?.clear(source: self.source)
                    return
                }
                try? self.mapLayerManager?.set(
                    shape: MGLPolylineFeature(
                        coordinates: self.waypoints.map {
                            CLLocationCoordinate2D(latitude: $0.latLng.latitude, longitude: $0.latLng.longitude)
                        },
                        count: UInt(self.waypoints.count)
                    ),
                    on: self.source
                )
            }
        }
    }

    @objc private var layerIdentifier: String = "DIRECTION_ARROW_LAYER_IDENTIFIER"

    private let routeLayer: MGLStyleLayer

    private lazy var source = MGLShapeSource(identifier: layerIdentifier, shapes: [], options: nil)

    private lazy var layer = RouteDirectionArrowsLayer(identifier: layerIdentifier, source: source)

    // MARK: Lifecycle

    init(
        mapLayerManager: MapboxMapLayerManager?,
        mapTheme: MapTheme,
        routeLayer: MGLStyleLayer
    ) {
        self.routeLayer = routeLayer
        super.init(mapLayerManager: mapLayerManager, mapTheme: mapTheme)
    }

    override func setup() {
        mapLayerManager?.add(source: source)
        try? mapLayerManager?.addRouteLineLayer(layer: layer)
        mapLayerManager?.add(image: .Map.routeDirectionArrow, for: "direction-arrow")
    }

    // MARK: Overridden Functions

    override func refreshLayerVisibility(isVisible: Bool) {
        if isVisible {
            mapLayerManager?.showLayer(with: routeLayer.identifier)
        } else {
            mapLayerManager?.hideLayer(with: routeLayer.identifier)
        }
    }
}
