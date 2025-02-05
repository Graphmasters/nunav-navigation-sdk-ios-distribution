import Foundation
import MultiplatformNavigation

final class DetachAwareRouteFeatureCreator: RouteFeatureCreator {
    // MARK: Nested Types

    private enum Error: Swift.Error {
        case polyLineTooShort
    }

    // MARK: Properties

    private let routeDetachStateProvider: RouteDetachStateProvider
    private let navigationSdk: NavigationSdk
    private let detachedRouteFeatureCreator: RouteFeatureCreator
    private let defaultSpeedFeatureCreator: RouteFeatureCreator

    // MARK: Lifecycle

    init(
        navigationSdk: NavigationSdk,
        routeDetachStateProvider: RouteDetachStateProvider,
        detachedRouteFeatureCreator: RouteFeatureCreator,
        defaultSpeedFeatureCreator: RouteFeatureCreator
    ) {
        self.routeDetachStateProvider = routeDetachStateProvider
        self.navigationSdk = navigationSdk
        self.detachedRouteFeatureCreator = detachedRouteFeatureCreator
        self.defaultSpeedFeatureCreator = defaultSpeedFeatureCreator
    }

    // MARK: Functions

    func createFeatures(waypoints: [Route.Waypoint]) throws -> [RouteFeatureCreatorRouteFeature] {
        guard waypoints.count > 1 else {
            throw Error.polyLineTooShort
        }
        if routeDetachStateProvider.detached, navigationSdk.navigationActive {
            return try detachedRouteFeatureCreator.createFeatures(waypoints: waypoints)
        } else {
            return try defaultSpeedFeatureCreator.createFeatures(waypoints: waypoints)
        }
    }
}
