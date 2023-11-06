import GMMapUtility
import Mapbox
import NunavSDKMultiplatform

public final class UserLocationLayerHandler: MGLStyleLayersHandler {
    private enum Constants {
        static let layerIdentifier: String = "current_location_map_layer"
        static let sourceIdentifier: String = "current_location_map_source"
        static let imageKey: String = "LOCATION_ICON_IMAGE_KEY"
    }

    @objc public var rotationKey: String = #keyPath(rotationKey)

    private let locationProvider: LocationProvider
    private let navigationSdk: NavigationSdk
    private let positionAnimatorFactory: PositionAnimatorFactory
    private let routeDetachStateProvider: RouteDetachStateProvider

    // MARK: - Life Cycle

    public init(
        mapLayerManager: MapboxMapLayerManager?,
        locationProvider: LocationProvider,
        navigationSdk: NavigationSdk,
        positionAnimatorFactory: PositionAnimatorFactory = TimerPositionAnimatorFactory(),
        routeDetachStateProvider: RouteDetachStateProvider
    ) {
        self.locationProvider = locationProvider
        self.navigationSdk = navigationSdk
        self.positionAnimatorFactory = positionAnimatorFactory
        self.routeDetachStateProvider = routeDetachStateProvider

        super.init(mapLayerManager: mapLayerManager)
    }

    override public func setup() {
        super.setup()
        mapLayerManager?.add(source: shapeSource)
        try? mapLayerManager?.addSymbolLayer(layer: layer)
        mapLayerManager?.add(image: currentLocationIcon, for: Constants.imageKey)
    }

    override public func startLayerUpdates() {
        super.startLayerUpdates()
        locationProvider.addLocationUpdateListener(locationUpdateListener: self)
    }

    override public func stopLayerUpdates() {
        locationProvider.removeLocationUpdateListener(locationUpdateListener: self)
    }

    private var currentLocationIcon: UIImage = Asset.Map.locationIconGray.image {
        didSet {
            guard oldValue != currentLocationIcon else {
                return
            }
            mapLayerManager?.remove(imageWithKey: Constants.imageKey)
            mapLayerManager?.add(image: currentLocationIcon, for: Constants.imageKey)
        }
    }

    private func refreshLocationIcon() {
        if routeDetachStateProvider.detached {
            currentLocationIcon = Asset.Map.locationIconGray.image
        } else {
            currentLocationIcon = Asset.Map.locationIcon.image
        }
    }

    override public func updateVisibility(_ visible: Bool) {
        if visible {
            mapLayerManager?.showLayer(with: layer.identifier)
        } else {
            mapLayerManager?.hideLayer(with: layer.identifier)
        }
    }

    // MARK: - Source and Layer

    private lazy var shapeSource = MGLShapeSource(identifier: Constants.sourceIdentifier,
                                                  shapes: [], options: nil)

    private func point(for location: Location) -> MGLPointFeature {
        return point(for: location.latLng, heading: Double(truncating: location.heading ?? 0))
    }

    private func point(for position: LatLng, heading: Double) -> MGLPointFeature {
        let point = MGLPointFeature()
        point.identifier = UUID().uuidString
        point.coordinate = position.clLocationCoordinate2D
        point.attributes[rotationKey] = heading
        return point
    }

    private lazy var layer: MGLStyleLayer = {
        let layer = DefaultIconLayer(identifier: Constants.layerIdentifier, source: shapeSource, minimumZoomLevel: 0)
        layer.iconImageName = NSExpression(forConstantValue: Constants.imageKey)
        layer.iconAnchor = NSExpression(forConstantValue: MGLIconAnchor.center.rawValue)
        layer.iconScale = NSExpression(
            forMGLInterpolating: NSExpression.zoomLevelVariable,
            curveType: .linear,
            parameters: nil,
            stops: NSExpression(forConstantValue: [
                16.5: 1.0,
                13.5: 0.5
            ])
        )
        layer.iconRotation = NSExpression(forKeyPath: rotationKey)
        layer.iconRotationAlignment = NSExpression(forConstantValue: MGLIconRotationAlignment.map.rawValue)
        layer.iconAllowsOverlap = NSExpression(forConstantValue: true)
        layer.textAllowsOverlap = NSExpression(forConstantValue: true)
        layer.iconIgnoresPlacement = NSExpression(forConstantValue: true)
        layer.textIgnoresPlacement = NSExpression(forConstantValue: true)
        return layer
    }()

    private var timer: Timer?

    private var shownPosition: Location? {
        didSet {
            DispatchQueue.main.async {
                guard let position = self.shownPosition else {
                    try? self.mapLayerManager?.clear(source: self.shapeSource)
                    return
                }

                try? self.mapLayerManager?.set(
                    shape: MGLShapeCollectionFeature(
                        shapes: [self.point(for: position.latLng, heading: Double(truncating: position.heading ?? 0))]
                    ),
                    on: self.shapeSource
                )
            }
        }
    }

    private weak var positionAnimator: PositionAnimator?
}

extension UserLocationLayerHandler: LocationProviderLocationUpdateListener {
    public func onLocationUpdated(location: Location) {
        guard !location.latLng.latitude.isNaN, !location.latLng.longitude.isNaN else {
            GMAnalytics.shared.postEvent(
                tag: nil,
                message: "[Error] Map location is invalid",
                properties: [
                    "latitude": location.latLng.latitude,
                    "longitude": location.latLng.longitude
                ]
            )
            return
        }
        refreshLocationIcon()

        positionAnimator?.cancelAnimation()
        let animator = positionAnimatorFactory.getPositionAnimator(start: shownPosition ?? location, end: location)
        positionAnimator = animator
        positionAnimator?.delegate = self
        positionAnimator?.startAnimation()
    }
}

extension UserLocationLayerHandler: PositionAnimatorDelegate {
    public func onUpdate(value: Location) {
        shownPosition = value
    }

    public func onFinish(value: Location) {
        shownPosition = value
    }

    public func onCancel() {}
}
