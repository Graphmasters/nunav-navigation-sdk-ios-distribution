import GMMapUtility
import Mapbox
import MultiplatformNavigation

final class LocationTrailMapLayerHandler: MGLStyleLayersHandler {
    // MARK: Nested Types

    private enum Constants {
        static let maxProbeDistance = Length.companion.fromMeters(meters: 8)
        static let maxTrailLength = 24
        static let sourceIdentifier = "probe_trail_source"
        static let layerIdentifier = "probe_trail_layer"
    }

    // MARK: Properties

    @objc private let circleColorKey: String = #keyPath(circleColorKey)
    @objc private let circleStrokeColorKey: String = #keyPath(circleStrokeColorKey)
    @objc private let opacityKey: String = #keyPath(opacityKey)

    private let mapLocationProvider: LocationProvider
    private let navigationSdk: NavigationSdk

    private lazy var shapeSource = MGLShapeSource(identifier: Constants.sourceIdentifier, features: [], options: nil)

    private lazy var layer: MGLStyleLayer = {
        let circleLayer = MGLCircleStyleLayer(identifier: Constants.layerIdentifier, source: self.shapeSource)
        circleLayer.minimumZoomLevel = 11
        circleLayer.circleColor = NSExpression(forKeyPath: self.circleColorKey)
        circleLayer.circleStrokeColor = NSExpression(forKeyPath: self.circleStrokeColorKey)
        circleLayer.circleOpacity = NSExpression(forKeyPath: self.opacityKey)
        circleLayer.circleStrokeOpacity = NSExpression(forKeyPath: self.opacityKey)
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

    // MARK: Computed Properties

    private var trail = [MultiplatformNavigation.Location]() {
        didSet {
            updateSource(from: trail)
        }
    }

    // MARK: Lifecycle

    init(
        mapLayerManager: MapboxMapLayerManager?,
        mapTheme: MapTheme,
        mapLocationProvider: LocationProvider,
        navigationSdk: NavigationSdk
    ) {
        self.mapLocationProvider = mapLocationProvider
        self.navigationSdk = navigationSdk

        super.init(mapLayerManager: mapLayerManager, mapTheme: mapTheme)
    }

    override func setup() {
        mapLayerManager?.add(source: shapeSource)
        try? mapLayerManager?.addRouteLineLayer(layer: layer)
    }

    override func startLayerUpdates() {
        mapLocationProvider.addLocationUpdateListener(locationUpdateListener: self)
        navigationSdk.addOnNavigationStoppedListener(onNavigationStoppedListener: self)
    }

    override func stopLayerUpdates() {
        mapLocationProvider.removeLocationUpdateListener(locationUpdateListener: self)
        navigationSdk.removeOnNavigationStoppedListener(onNavigationStoppedListener: self)
    }

    // MARK: Overridden Functions

    override func refreshLayerVisibility(isVisible visible: Bool) {
        if visible {
            mapLayerManager?.showLayer(with: layer.identifier)
        } else {
            mapLayerManager?.hideLayer(with: layer.identifier)
        }
    }

    // MARK: Functions

    private func getCircleStrokeColor(for _: Speed) -> UIColor {
        if navigationSdk.navigationState?.displayInformation.shouldShowUserOffRoute != false {
            return UIColor(hex: DetachConstants.shared.ROUTE_OUTLINE_COLOR) ?? .clear
        }
        return UIColor(hex: "#005f97") ?? .clear
    }

    private func getCircleColor(for _: Speed) -> UIColor {
        if navigationSdk.navigationState?.displayInformation.shouldShowUserOffRoute != false {
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
            feature.coordinate = CLLocationCoordinate2D(
                latitude: location.element.latLng.latitude,
                longitude: location.element.latLng.longitude
            )
            feature.attributes[circleColorKey] = getCircleColor(for: speed)
            feature.attributes[circleStrokeColorKey] = getCircleStrokeColor(for: speed)
            feature.attributes[opacityKey] = Double(trail.count - location.offset) / Double(trail.count)
            features.append(feature)
        }
        try? mapLayerManager?.set(shape: MGLShapeCollectionFeature(shapes: features), on: shapeSource)
    }
}

extension LocationTrailMapLayerHandler: LocationProviderLocationUpdateListener {
    func onLocationUpdated(location: Location) {
        guard canAdd(location) else {
            return
        }
        guard navigationSdk.navigationState?.initialized == true else {
            return trail.removeAll()
        }

        if trail.count >= Constants.maxTrailLength {
            trail.removeLast()
        }
        trail.insert(location, at: 0)
    }

    private func canAdd(_ location: Location) -> Bool {
        guard let first = trail.first else {
            return true
        }
        let distance = Geodesy.shared.pointToPointDistance(
            start: location.latLng,
            end: first.latLng
        )
        return distance.inMeters() > Constants.maxProbeDistance.inMeters()
    }
}

extension LocationTrailMapLayerHandler: NavigationEventHandlerOnNavigationStoppedListener {
    func onNavigationStopped() {
        trail = []
    }
}
