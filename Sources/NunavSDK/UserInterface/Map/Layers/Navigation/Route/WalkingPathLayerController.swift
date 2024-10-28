import GMMapUtility
import Mapbox
import NunavDesignSystem
import NunavSDKMultiplatform

public final class WalkingPathLayerController: MGLStyleLayersHandler {
    // MARK: Properties

    @objc private lazy var layerIdentifier: String = identifierPrefix + "WALKING_PATH_LAYER_IDENTIFIER"

    private let identifierPrefix: String

    private var straightLine: MGLShape?
    private var bezierPolyLine: MGLShape?

    private lazy var source = MGLShapeSource(identifier: layerIdentifier, shapes: [], options: nil)

    private lazy var layer: MGLStyleLayer = DashedLineLayer(
        identifier: layerIdentifier,
        source: source,
        lineColor: .DesignSystem.onSurfaceSecondary
    )

    // MARK: Computed Properties

    public var route: Route? {
        didSet {
            refresh()
            updateTiltFromMapViewCamera()
        }
    }

    // MARK: Lifecycle

    public init(
        mapLayerManager: MapboxMapLayerManager?,
        mapTheme: MapTheme,
        identifierPrefix: String
    ) {
        self.identifierPrefix = identifierPrefix

        super.init(mapLayerManager: mapLayerManager, mapTheme: mapTheme)
    }

    override public func setup() {
        mapLayerManager?.add(shapeSource: source, useFeatureCache: true)
        try? mapLayerManager?.addRouteLineLayer(layer: layer)
    }

    // MARK: Overridden Functions

    override public func updateVisibility(_ visible: Bool) {
        if visible {
            mapLayerManager?.showLayer(with: layer.identifier)
        } else {
            mapLayerManager?.hideLayer(with: layer.identifier)
        }
    }

    override public func updateTilt(tilt: Float) {
        try? mapLayerManager?.set(shape: tilt < 20 ? bezierPolyLine : straightLine, on: source)
    }

    // MARK: Functions

    private func refresh() {
        straightLine = route.map(straightPolyline) ?? nil
        bezierPolyLine = route.map(bezierPolyline) ?? nil
    }

    private func updateTiltFromMapViewCamera() {
        guard let mapView = mapLayerManager?.mapView else {
            return
        }
        updateTilt(tilt: Float(mapView.camera.pitch))
    }

    private func straightPolyline(for route: Route) -> MGLShape? {
        guard let lastPoint = route.waypoints.last else {
            return nil
        }
        let destination = route.destinationInformation.latLng
        let coordinates = [lastPoint.latLng, destination].map {
            CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
        }
        return MGLPolylineFeature(coordinates: coordinates, count: UInt(coordinates.count))
    }

    private func bezierPolyline(for route: Route) -> MGLShape? {
        guard let lastPoint = route.waypoints.last?.latLng.clLocationCoordinate2D else {
            return nil
        }
        let destination = route.destinationInformation.latLng.clLocationCoordinate2D
        return MGLPolylineFeature.geodesicPolyline(fromCoordinate: lastPoint, toCoordinate: destination)
    }
}
