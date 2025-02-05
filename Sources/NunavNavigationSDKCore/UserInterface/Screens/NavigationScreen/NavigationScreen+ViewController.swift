import CoreLocation
import Foundation
import GMCoreUtility
import MultiplatformNavigation
import SwiftUI
import UIKit

extension NavigationScreen {
    public final class ViewController: UIHostingController<NavigationScreen> {
        // MARK: Properties

        private let routable: Routable
        private let vehicleConfig: VehicleConfig
        private let routeOptions: RouteOptions
        private let navigationSdk: NavigationSdk

        private let navigationViewModel: NavigationScreen.ViewModel
        private let routeProgressViewModel: RouteProgressViewModel
        private let maneuverViewModel: ManeuverCard.ViewModel

        private let locationProvider: LocationProvider
        private let voiceInstructionComponent: VoiceInstructionComponent

        private let displayDimmingController = DisplayDimmingController()

        // MARK: Lifecycle

        public init(
            routable: Routable,
            vehicleConfig: VehicleConfig,
            routeOptions: RouteOptions,
            navigationSdk: NavigationSdk,
            routeDetachStateProvider: RouteDetachStateProvider,
            mapLocationProvider: LocationProvider,
            locationProvider: LocationProvider,
            voiceInstructionComponent: VoiceInstructionComponent
        ) {
            self.routable = routable
            self.vehicleConfig = vehicleConfig
            self.routeOptions = routeOptions
            self.navigationSdk = navigationSdk

            self.locationProvider = locationProvider

            let navigationViewModel = NavigationScreen.ViewModel(
                navigationSdk: navigationSdk,
                locationProvider: mapLocationProvider,
                routeDetachStateProvider: routeDetachStateProvider
            )

            let routeProgressViewModel = RouteProgressViewModel(
                navigationSdk: navigationSdk,
                detachStateProvider: routeDetachStateProvider,
                routeProgressUIStateConverter: RouteProgressUIStateConverter()
            )

            let maneuverViewModel = ManeuverCard.ViewModel(
                navigationSdk: navigationSdk,
                detachStateProvider: routeDetachStateProvider,
                maneuverUIStateConverter: ManeuverUIStateConverter()
            )

            self.navigationViewModel = navigationViewModel
            self.routeProgressViewModel = routeProgressViewModel
            self.maneuverViewModel = maneuverViewModel

            self.voiceInstructionComponent = voiceInstructionComponent

            super.init(
                rootView: NavigationScreen(
                    navigationViewModel: navigationViewModel,
                    routeProgressViewModel: routeProgressViewModel,
                    mapLocationProvider: mapLocationProvider,
                    navigationSdk: navigationSdk,
                    routeDetachStateProvider: routeDetachStateProvider
                )
            )

            navigationViewModel.dismissNavigation = { [weak self] in
                self?.dismiss(animated: true)
            }

            isModalInPresentation = true
            modalPresentationStyle = .fullScreen
        }

        @available(*, unavailable)
        @MainActor dynamic required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        // MARK: Overridden Functions

        override public func viewDidLoad() {
            super.viewDidLoad()

            locationProvider.addLocationUpdateListener(locationUpdateListener: self)
            locationProvider.startLocationUpdates()
            locationProvider.lastKnownLocation.map {
                navigationSdk.updateLocation(location: $0)
            }

            voiceInstructionComponent.enabled = true
            navigationViewModel.toggleVoiceInstructionComponent = toggleVoiceInstructionComponent

            CLLocationManager().requestWhenInUseAuthorization()

            // TODO:

            try? navigationSdk.startNavigation(
                routable: routable,
                vehicleConfig: vehicleConfig,
                routeOptions: routeOptions
            )

            displayDimmingController.disableAutomaticDimmming()
        }

        override public func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)

            guard !navigationSdk.navigationActive else {
                return
            }

            displayDimmingController.enableAutomaticDimmming()

            dismiss(animated: true)
        }

        override public func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)

            guard !navigationSdk.navigationActive else {
                return
            }

            locationProvider.removeLocationUpdateListener(locationUpdateListener: self)
        }

        // MARK: Functions

        func toggleVoiceInstructionComponent() {
            voiceInstructionComponent.enabled.toggle()
        }
    }
}

extension NavigationScreen.ViewController: LocationProviderLocationUpdateListener {
    public func onLocationUpdated(location: Location) {
        navigationSdk.updateLocation(location: location)
    }
}
