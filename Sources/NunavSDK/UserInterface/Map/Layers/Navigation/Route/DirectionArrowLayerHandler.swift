import GMMapUtility
import Mapbox
import NunavSDKMultiplatform

public final class DirectionArrowLayerHandler: MGLStyleLayersHandler {
    // MARK: Properties

    @objc private var layerIdentifier: String = "DIRECTION_ARROW_LAYER_IDENTIFIER"

    private let routeLayer: MGLStyleLayer

    private lazy var source = MGLShapeSource(identifier: layerIdentifier, shapes: [], options: nil)

    private lazy var layer = RouteDirectionArrowsLayer(identifier: layerIdentifier, source: source)

    // MARK: Computed Properties

    public var waypoints: [Route.Waypoint] = [] {
        didSet {
            DispatchQueue.main.async {
                guard self.waypoints.count > 1 else {
                    try? self.mapLayerManager?.clear(source: self.source)
                    return
                }
                try? self.mapLayerManager?.set(
                    shape: MGLPolylineFeature(coordinates: self.waypoints.map { $0.latLng.clLocationCoordinate2D },
                                              count: UInt(self.waypoints.count)),
                    on: self.source
                )
            }
        }
    }

    // MARK: Lifecycle

    public init(
        mapLayerManager: MapboxMapLayerManager?,
        mapTheme: MapTheme,
        routeLayer: MGLStyleLayer
    ) {
        self.routeLayer = routeLayer
        super.init(mapLayerManager: mapLayerManager, mapTheme: mapTheme)
    }

    override public func setup() {
        mapLayerManager?.add(source: source)
        try? mapLayerManager?.addRouteLineLayer(layer: layer)
        mapLayerManager?.add(image: Asset.Map.routeDirectionArrow.image, for: "direction-arrow")
    }

    // MARK: Overridden Functions

    override public func updateVisibility(_ visible: Bool) {
        if visible {
            mapLayerManager?.showLayer(with: routeLayer.identifier)
        } else {
            mapLayerManager?.hideLayer(with: routeLayer.identifier)
        }
    }
}
