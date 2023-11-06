import GMMapUtility
import Mapbox
import NunavSDKMultiplatform

public final class LocationTrailMapLayerHandler: MGLStyleLayersHandler {
    private enum Constants {
        static let maxProbeDistance = Length.companion.fromMeters(meters: 8)
        static let maxTrailLength = 24
        static let sourceIdentifier = "probe_trail_source"
        static let layerIdentifier = "probe_trail_layer"
    }

    @objc private let circleColorKey: String = #keyPath(circleColorKey)
    @objc private let circleStrokeColorKey: String = #keyPath(circleStrokeColorKey)
    @objc private let opacityKey: String = #keyPath(opacityKey)

    private let mapLocationProvider: LocationProvider
    private let navigationSdk: NavigationSdk
    private let routeDetachStateProvider: RouteDetachStateProvider

    // MARK: - Attributes

    private var trail = [Location]() {
        didSet {
            updateSource(from: trail)
        }
    }

    // MARK: - Life Cycle

    public init(
        mapLayerManager: MapboxMapLayerManager?,
        mapLocationProvider: LocationProvider,
        navigationSdk: NavigationSdk,
        routeDetachStateProvider: RouteDetachStateProvider
    ) {
        self.mapLocationProvider = mapLocationProvider
        self.navigationSdk = navigationSdk
        self.routeDetachStateProvider = routeDetachStateProvider

        super.init(mapLayerManager: mapLayerManager)
    }

    override public func setup() {
        mapLayerManager?.add(source: shapeSource)
        try? mapLayerManager?.addRouteLineLayer(layer: layer)
    }

    override public func startLayerUpdates() {
        mapLocationProvider.addLocationUpdateListener(locationUpdateListener: self)
        navigationSdk.addOnNavigationStoppedListener(onNavigationStoppedListener: self)
    }

    override public func stopLayerUpdates() {
        mapLocationProvider.removeLocationUpdateListener(locationUpdateListener: self)
        navigationSdk.removeOnNavigationStoppedListener(onNavigationStoppedListener: self)
    }

    override public func updateVisibility(_ visible: Bool) {
        if visible {
            mapLayerManager?.showLayer(with: layer.identifier)
        } else {
            mapLayerManager?.hideLayer(with: layer.identifier)
        }
    }

    private lazy var shapeSource = MGLShapeSource(identifier: Constants.sourceIdentifier, features: [], options: nil)

    private lazy var layer: MGLStyleLayer = {
        let circleLayer = MGLCircleStyleLayer(identifier: Constants.layerIdentifier, source: shapeSource)
        circleLayer.minimumZoomLevel = 11
        circleLayer.circleColor = NSExpression(forKeyPath: circleColorKey)
        circleLayer.circleStrokeColor = NSExpression(forKeyPath: circleStrokeColorKey)
        circleLayer.circleOpacity = NSExpression(forKeyPath: opacityKey)
        circleLayer.circleStrokeOpacity = NSExpression(forKeyPath: opacityKey)
        circleLayer.circleRadius = NSExpression(
            forMGLInterpolating: .zoomLevelVariable,
            curveType: .linear, parameters: nil,
            stops: NSExpression(forConstantValue: [
                13: 1,
                18: 5
            ])
        )
        circleLayer.circlePitchAlignment = NSExpression(forConstantValue: "map")
        circleLayer.circleStrokeWidth = NSExpression(forConstantValue: 1)
        return circleLayer
    }()

    private func getCircleStrokeColor(for _: Speed) -> UIColor {
        if routeDetachStateProvider.detached {
            return UIColor(hex: DetachConstants.shared.ROUTE_OUTLINE_COLOR) ?? .clear
        }
        return UIColor(hex: "#005f97") ?? .clear
    }

    private func getCircleColor(for _: Speed) -> UIColor {
        if routeDetachStateProvider.detached {
            return UIColor(hex: DetachConstants.shared.ROUTE_FILL_COLOR) ?? .clear
        }
        return UIColor(hex: "#4b8cc8") ?? .clear
    }

    private func color(for speed: Speed) -> UIColor {
        let maximumSpeed: Double = 200
        let normalizedSpeed = speed.inKmh() / maximumSpeed
        let maximumHue: CGFloat = 5 / 7
        return UIColor(hue: CGFloat(normalizedSpeed) * maximumHue, saturation: 0.85, brightness: 0.9, alpha: 1)
    }

    private func updateSource(from trail: [Location]) {
        var features = [MGLPointFeature]()

        for location in trail.enumerated() {
            guard let speed = location.element.speed else {
                continue
            }
            let feature = MGLPointFeature()
            feature.coordinate = location.element.latLng.clLocationCoordinate2D
            feature.attributes[circleColorKey] = getCircleColor(for: speed)
            feature.attributes[circleStrokeColorKey] = getCircleStrokeColor(for: speed)
            feature.attributes[opacityKey] = Double(trail.count - location.offset) / Double(trail.count)
            features.append(feature)
        }
        try? mapLayerManager?.set(shape: MGLShapeCollectionFeature(shapes: features), on: shapeSource)
    }
}

extension LocationTrailMapLayerHandler: LocationProviderLocationUpdateListener {
    public func onLocationUpdated(location: Location) {
        guard canAdd(location) else { return }
        guard navigationSdk.navigationState?.initialized == true else {
            return trail.removeAll()
        }

        if trail.count >= Constants.maxTrailLength {
            trail.removeLast()
        }
        trail.insert(location, at: 0)
    }

    private func canAdd(_ location: Location) -> Bool {
        guard let first = trail.first else { return true }
        let distance = Geodesy.shared.pointToPointDistance(
            start: location.latLng,
            end: first.latLng
        )
        return distance > Constants.maxProbeDistance
    }
}

extension LocationTrailMapLayerHandler: NavigationEventHandlerOnNavigationStoppedListener {
    public func onNavigationStopped() {
        trail = []
    }
}
