import GMMapUtility
import Mapbox
import MultiplatformNavigation
import UIKit

final class NavigationTripSymbolsLayerHandler: TripSymbolsLayerHandler {
    // MARK: Properties

    private let navigationSdk: NavigationSdk

    // MARK: Lifecycle

    init(
        mapLayerManager: MapboxMapLayerManager?,
        mapTheme: MapTheme,
        navigationSdk: NavigationSdk
    ) {
        self.navigationSdk = navigationSdk

        super.init(
            identifierPrefix: "NAVIGATION_",
            mapLayerManager: mapLayerManager,
            mapTheme: mapTheme
        )
    }

    override func startLayerUpdates() {
        super.startLayerUpdates()

        navigationSdk.addOnNavigationStartedListener(onNavigationStartedListener: self)
        navigationSdk.addOnNavigationStoppedListener(onNavigationStoppedListener: self)
        navigationSdk.addOnRouteUpdateListener(onRouteUpdateListener: self)
        navigationSdk.addOnCurrentDestinationChangedListener(onCurrentDestinationChangedListener: self)
        navigationSdk.addOnNavigationStateInitializedListener(
            onNavigationStateInitializedListener: self)
        navigationSdk.addOnDestinationsChangedListener(onDestinationsChangedListener: self)
    }

    override func stopLayerUpdates() {
        super.stopLayerUpdates()
        navigationSdk.removeOnNavigationStartedListener(onNavigationStartedListener: self)
        navigationSdk.removeOnNavigationStoppedListener(onNavigationStoppedListener: self)
        navigationSdk.removeOnRouteUpdateListener(onRouteUpdateListener: self)
        navigationSdk.removeOnCurrentDestinationChangedListener(onCurrentDestinationChangedListener: self)
        navigationSdk.removeOnNavigationStateInitializedListener(
            onNavigationStateInitializedListener: self)
        navigationSdk.removeOnDestinationsChangedListener(onDestinationsChangedListener: self)
    }

    // MARK: Functions

    private func refreshLayer() {
        MainThread.shared.execute {
            guard self.navigationSdk.navigationActive else {
                return self.clearLayer()
            }
            if let route = self.navigationSdk.navigationState?.route,
               route.destination.id == self.navigationSdk.destinationRepository.destinations.first?.id {
                self.refresh(
                    destinations: Array(
                        self.navigationSdk.destinationRepository.destinations.dropFirst()
                    ).map { $0.latLng },
                    route: route
                )
            } else {
                self.refresh(destinations: self.navigationSdk.destinationRepository.destinations.map { $0.latLng }, route: nil)
            }
        }
    }

    private func clearLayer() {
        refresh(destinations: nil)
    }
}

extension NavigationTripSymbolsLayerHandler: NavigationEventHandlerOnNavigationStartedListener {
    func onNavigationStarted(routable _: Routable) {
        refreshLayer()
    }
}

extension NavigationTripSymbolsLayerHandler: NavigationEventHandlerOnNavigationStoppedListener {
    func onNavigationStopped() {
        refreshLayer()
    }
}

extension NavigationTripSymbolsLayerHandler: OnNavigationStateInitializedListener {
    func onNavigationStateInitialized(navigationState _: NavigationState) {
        refreshLayer()
    }
}

extension NavigationTripSymbolsLayerHandler: NavigationEventHandlerOnRouteUpdateListener {
    func onRouteUpdated(route _: Route) {
        refreshLayer()
    }
}

extension NavigationTripSymbolsLayerHandler: OnCurrentDestinationChangedListener {
    func onCurrentDestinationChanged(destination _: Routable?) {
        refreshLayer()
    }
}

extension NavigationTripSymbolsLayerHandler: OnDestinationsChangedListener {
    func onDestinationsChanged(destination _: [Routable]) {
        refreshLayer()
    }
}
