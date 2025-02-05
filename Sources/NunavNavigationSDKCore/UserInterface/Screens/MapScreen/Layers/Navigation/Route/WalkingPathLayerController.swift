import GMMapUtility
import Mapbox
import MultiplatformNavigation
import NunavDesignSystem

final class WalkingPathLayerController: MGLStyleLayersHandler {
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

    var route: Route? {
        didSet {
            refresh()
            updateTiltFromMapViewCamera()
        }
    }

    // MARK: Lifecycle

    init(
        mapLayerManager: MapboxMapLayerManager?,
        mapTheme: MapTheme,
        identifierPrefix: String
    ) {
        self.identifierPrefix = identifierPrefix

        super.init(mapLayerManager: mapLayerManager, mapTheme: mapTheme)
    }

    override func setup() {
        mapLayerManager?.add(shapeSource: source, useFeatureCache: true)
        try? mapLayerManager?.addRouteLineLayer(layer: layer)
    }

    // MARK: Overridden Functions

    override func refreshLayerVisibility(isVisible: Bool) {
        if isVisible {
            mapLayerManager?.showLayer(with: layer.identifier)
        } else {
            mapLayerManager?.hideLayer(with: layer.identifier)
        }
    }

    override func refreshLayerTilt(tilt: Float) {
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
        guard let lastPoint = route.waypoints.last?.latLng else {
            return nil
        }

        return MGLPolylineFeature.geodesicPolyline(
            fromCoordinate: CLLocationCoordinate2D(
                latitude: lastPoint.latitude,
                longitude: lastPoint.longitude
            ),
            toCoordinate: CLLocationCoordinate2D(
                latitude: route.destinationInformation.latLng.latitude,
                longitude: route.destinationInformation.latLng.longitude
            )
        )
    }
}
