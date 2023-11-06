import GMMapUtility
import Mapbox
import NunavDesignSystem
import NunavSDKMultiplatform

public final class WalkingPathLayerController: MGLStyleLayersHandler {
    @objc private lazy var layerIdentifier: String = identifierPrefix + "WALKING_PATH_LAYER_IDENTIFIER"

    private let identifierPrefix: String

    // MARK: - Life Cycle

    public init(
        mapLayerManager: MapboxMapLayerManager?,
        identifierPrefix: String
    ) {
        self.identifierPrefix = identifierPrefix

        super.init(mapLayerManager: mapLayerManager)
    }

    override public func setup() {
        mapLayerManager?.add(shapeSource: source, useFeatureCache: true)
        try? mapLayerManager?.addRouteLineLayer(layer: layer)
    }

    // MARK: - State

    public var route: Route? {
        didSet {
            refresh()
            updateTiltFromMapViewCamera()
        }
    }

    private var straightLine: MGLShape?
    private var bezierPolyLine: MGLShape?

    private func refresh() {
        straightLine = route.map(straightPolyline) ?? nil
        bezierPolyLine = route.map(bezierPolyline) ?? nil
    }

    override public func updateVisibility(_ visible: Bool) {
        if visible {
            mapLayerManager?.showLayer(with: layer.identifier)
        } else {
            mapLayerManager?.hideLayer(with: layer.identifier)
        }
    }

    private func updateTiltFromMapViewCamera() {
        guard let mapView = mapLayerManager?.mapView else {
            return
        }
        updateTilt(tilt: Float(mapView.camera.pitch))
    }

    override public func updateTilt(tilt: Float) {
        try? mapLayerManager?.set(shape: tilt < 20 ? bezierPolyLine : straightLine, on: source)
    }

    private func straightPolyline(for route: Route) -> MGLShape? {
        guard let lastPoint = route.waypoints.last else { return nil }
        let destination = self.destination(from: route)
        let coordinates = [lastPoint.latLng, destination].map {
            CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
        }
        return MGLPolylineFeature(coordinates: coordinates, count: UInt(coordinates.count))
    }

    private func bezierPolyline(for route: Route) -> MGLShape? {
        guard let lastPoint = route.waypoints.last?.latLng.clLocationCoordinate2D else { return nil }
        let destination = self.destination(from: route).clLocationCoordinate2D
        return MGLPolylineFeature.geodesicPolyline(fromCoordinate: lastPoint, toCoordinate: destination)
    }

    private func destination(from route: Route) -> LatLng {
        if route.destinationInfo.count > 0 {
            for destinationInfo in route.destinationInfo {
                switch destinationInfo.type {
                case "destination":
                    return destinationInfo.location
                default:
                    break
                }
            }
        }
        return route.destination.latLng
    }

    // MARK: - Source and Layer

    private lazy var source = MGLShapeSource(identifier: layerIdentifier, shapes: [], options: nil)

    private lazy var layer: MGLStyleLayer = DashedLineLayer(
        identifier: layerIdentifier,
        source: source,
        lineColor: .DesignSystem.onSurfaceSecondary
    )
}
