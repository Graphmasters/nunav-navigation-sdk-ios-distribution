import Foundation
import GMCoreUtility
import GMMapUtility
import Mapbox
import MultiplatformNavigation

class NavigationLayerHandler: AggregatingMGLStyleLayersHandler {
    // MARK: Nested Types

    private enum Constants {
        static let layerIdentifierPrefix = "NAVIGATION_"
    }

    // MARK: Properties

    private let navigationSdk: NavigationSdk
    private let routeFeatureCreator: RouteFeatureCreator
    private let mapLocationProvider: LocationProvider

    private var observation: NSKeyValueObservation?

    private lazy var locationTrailMapLayerHandler = LocationTrailMapLayerHandler(
        mapLayerManager: mapLayerManager,
        mapTheme: mapTheme,
        mapLocationProvider: mapLocationProvider,
        navigationSdk: navigationSdk
    )

    private lazy var walkingPathLayerController = WalkingPathLayerController(
        mapLayerManager: mapLayerManager,
        mapTheme: mapTheme,
        identifierPrefix: Constants.layerIdentifierPrefix
    )

    private lazy var routeLayerController = RouteLineLayerHandler(
        mapLayerManager: mapLayerManager,
        mapTheme: mapTheme,
        featureCreator: routeFeatureCreator,
        identifierPrefix: Constants.layerIdentifierPrefix
    )

    private lazy var directionArrowLayerHandler = DirectionArrowLayerHandler(
        mapLayerManager: mapLayerManager,
        mapTheme: mapTheme,
        routeLayer: routeLayerController.firstPartRouteLayer
    )

    private lazy var maneuverArrowLayerHandler = RouteTurnCommandArrowsLayerHandler(
        mapTheme: mapTheme,
        mapLayerManager: mapLayerManager,
        navigationSdk: navigationSdk
    )

    private lazy var tripSymbolsLayerController = NavigationTripSymbolsLayerHandler(
        mapLayerManager: mapLayerManager,
        mapTheme: mapTheme,
        navigationSdk: navigationSdk
    )

    // MARK: Lifecycle

    init(
        mapLayerManager: MapboxMapLayerManager?,
        navigationSdk: NavigationSdk,
        mapTheme: MapTheme,
        routeFeatureCreator: RouteFeatureCreator,
        mapLocationProvider: LocationProvider
    ) {
        self.navigationSdk = navigationSdk
        self.routeFeatureCreator = routeFeatureCreator
        self.mapLocationProvider = mapLocationProvider

        super.init(
            mapLayerManager: mapLayerManager,
            mapTheme: mapTheme,
            layerHandlers: []
        )

        layerHandlers = [
            locationTrailMapLayerHandler,
            walkingPathLayerController,
            routeLayerController,
            directionArrowLayerHandler,
            tripSymbolsLayerController,
            maneuverArrowLayerHandler
        ]
    }

    override func startLayerUpdates() {
        super.startLayerUpdates()

        mapLocationProvider.addLocationUpdateListener(locationUpdateListener: self)
        navigationSdk.addOnNavigationStartedListener(onNavigationStartedListener: self)
        navigationSdk.addOnNavigationStoppedListener(onNavigationStoppedListener: self)
        navigationSdk.addOnRouteUpdateListener(onRouteUpdateListener: self)
    }

    override func stopLayerUpdates() {
        super.stopLayerUpdates()

        mapLocationProvider.removeLocationUpdateListener(locationUpdateListener: self)
        navigationSdk.removeOnNavigationStartedListener(onNavigationStartedListener: self)
        navigationSdk.removeOnNavigationStoppedListener(onNavigationStoppedListener: self)
        navigationSdk.removeOnRouteUpdateListener(onRouteUpdateListener: self)
        observation?.invalidate()
        observation = nil
    }
}

extension NavigationLayerHandler: NavigationEventHandlerOnRouteUpdateListener {
    func onRouteUpdated(route: Route) {
        walkingPathLayerController.route = route
        directionArrowLayerHandler.waypoints = route.waypoints
    }
}

extension NavigationLayerHandler: LocationProviderLocationUpdateListener {
    func onLocationUpdated(location: Location) {
        guard navigationSdk.destinationRepository.destinations.first?.id == navigationSdk.navigationState?.route?.destination.id,
              let projection = location as? OnRouteProjectorProjectedLocation
              ?? navigationSdk.navigationState?.routeProgress?.locationOnRoute else {
            return clearRoute()
        }
        routeLayerController.waypoints = RouteUtils().sliceByProjection(
            waypoints: projection.route.waypoints, projectedLocation: projection
        )
    }

    private func clearRoute() {
        routeLayerController.waypoints = []
        directionArrowLayerHandler.waypoints = []
        walkingPathLayerController.route = nil
    }
}

extension NavigationLayerHandler: NavigationEventHandlerOnNavigationStartedListener {
    func onNavigationStarted(routable _: Routable) {
        clearRoute()
    }
}

extension NavigationLayerHandler: NavigationEventHandlerOnNavigationStoppedListener {
    func onNavigationStopped() {
        clearRoute()
    }
}
