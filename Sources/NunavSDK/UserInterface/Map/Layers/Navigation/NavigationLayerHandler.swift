import Foundation
import GMCoreUtility
import GMMapUtility
import Mapbox
import NunavSDKMultiplatform

public class NavigationLayerHandler: AggregatingMGLStyleLayersHandler {
    private enum Constants {
        static let layerIdentifierPrefix = "NAVIGATION_"
    }

    private let navigationSdk: NavigationSdk
    private let mapTheme: MapTheme
    private let routeFeatureCreator: RouteFeatureCreator
    private let mapLocationProvider: LocationProvider
    private let routeDetachStateProvider: RouteDetachStateProvider

    private var observation: NSKeyValueObservation?

    public init(
        mapLayerManager: MapboxMapLayerManager?,
        navigationSdk: NavigationSdk,
        mapTheme: MapTheme,
        routeFeatureCreator: RouteFeatureCreator,
        mapLocationProvider: LocationProvider,
        routeDetachStateProvider: RouteDetachStateProvider
    ) {
        self.navigationSdk = navigationSdk
        self.mapTheme = mapTheme
        self.routeFeatureCreator = routeFeatureCreator
        self.mapLocationProvider = mapLocationProvider
        self.routeDetachStateProvider = routeDetachStateProvider

        super.init(
            mapLayerManager: mapLayerManager,
            layerHandlers: []
        )

        layerHandlers = [
            locationTrailMapLayerHandler,
            walkingPathLayerController,
            routeLayerController,
            directionArrowLayerHandler,
            tripSymbolsLayerController,
            maneuverLayerHandler
        ]
    }

    override public func startLayerUpdates() {
        super.startLayerUpdates()

        mapLocationProvider.addLocationUpdateListener(locationUpdateListener: self)
        navigationSdk.addOnNavigationStartedListener(onNavigationStartedListener: self)
        navigationSdk.addOnNavigationStoppedListener(onNavigationStoppedListener: self)
        navigationSdk.addOnRouteUpdateListener(onRouteUpdateListener: self)
    }

    override public func stopLayerUpdates() {
        super.stopLayerUpdates()

        mapLocationProvider.removeLocationUpdateListener(locationUpdateListener: self)
        navigationSdk.removeOnNavigationStartedListener(onNavigationStartedListener: self)
        navigationSdk.removeOnNavigationStoppedListener(onNavigationStoppedListener: self)
        navigationSdk.removeOnRouteUpdateListener(onRouteUpdateListener: self)
        observation?.invalidate()
        observation = nil
    }

    private lazy var locationTrailMapLayerHandler = LocationTrailMapLayerHandler(
        mapLayerManager: mapLayerManager,
        mapLocationProvider: mapLocationProvider,
        navigationSdk: navigationSdk,
        routeDetachStateProvider: routeDetachStateProvider
    )

    private lazy var walkingPathLayerController = WalkingPathLayerController(
        mapLayerManager: mapLayerManager,
        identifierPrefix: Constants.layerIdentifierPrefix
    )

    private lazy var routeLayerController = RouteLineLayerHandler(
        mapLayerManager: mapLayerManager,
        featureCreator: routeFeatureCreator,
        identifierPrefix: Constants.layerIdentifierPrefix
    )

    private lazy var directionArrowLayerHandler = DirectionArrowLayerHandler(
        mapLayerManager: mapLayerManager,
        routeLayer: routeLayerController.firstPartRouteLayer
    )

    private lazy var tripSymbolsLayerController = NavigationTripSymbolsLayerHandler(
        mapLayerManager: mapLayerManager,
        mapTheme: mapTheme,
        navigationSdk: navigationSdk
    )

    private lazy var maneuverLayerHandler: ManeuverLayerHandler = .init(
        mapLayerManager: mapLayerManager,
        maneuverMapIconCreator: SwiftChipManeuverMapIconCreator(maneuverImageProvider: DefaultManeuverImageProvider())
    )
}

extension NavigationLayerHandler: NavigationEventHandlerOnRouteUpdateListener {
    public func onRouteUpdated(route: Route) {
        walkingPathLayerController.route = route
        directionArrowLayerHandler.waypoints = route.waypoints
        maneuverLayerHandler.maneuvers = routeDetachStateProvider.detached ? []
            : Array((navigationSdk.navigationState?.routeProgress?.remainingManeuvers ?? []).prefix(1))
    }
}

extension NavigationLayerHandler: LocationProviderLocationUpdateListener {
    public func onLocationUpdated(location: Location) {
        guard navigationSdk.destinationRepository.destinations.first?.id == navigationSdk.navigationState?.route?.destination.id,
              let projection = location as? OnRouteProjectorProjectedLocation
              ?? navigationSdk.navigationState?.routeProgress?.locationOnRoute else {
            return clearRoute()
        }
        routeLayerController.waypoints = RouteUtils().sliceByProjection(
            waypoints: projection.route.waypoints, projectedLocation: projection
        )
        maneuverLayerHandler.maneuvers = routeDetachStateProvider.detached ? []
            : Array((navigationSdk.navigationState?.routeProgress?.remainingManeuvers ?? []).prefix(1))
    }

    private func clearRoute() {
        maneuverLayerHandler.maneuvers = []
        routeLayerController.waypoints = []
        directionArrowLayerHandler.waypoints = []
        walkingPathLayerController.route = nil
    }
}

extension NavigationLayerHandler: NavigationEventHandlerOnNavigationStartedListener {
    public func onNavigationStarted(routable _: Routable) {
        clearRoute()
    }
}

extension NavigationLayerHandler: NavigationEventHandlerOnNavigationStoppedListener {
    public func onNavigationStopped() {
        clearRoute()
    }
}
