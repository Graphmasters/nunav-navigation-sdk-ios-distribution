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

        private var startNavigationTask: Task<Void, Error>?

        private var initiallyStarted = false

        // MARK: Lifecycle

        public init(
            routable: Routable,
            vehicleConfig: VehicleConfig,
            routeOptions: RouteOptions,
            navigationSdk: NavigationSdk,
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
                locationProvider: mapLocationProvider
            )

            let routeProgressViewModel = RouteProgressViewModel(
                navigationSdk: navigationSdk,
                routeProgressUIStateConverter: RouteProgressUIStateConverter()
            )

            let maneuverViewModel = ManeuverCard.ViewModel(
                navigationSdk: navigationSdk,
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
                    navigationSdk: navigationSdk
                )
            )

            navigationViewModel.dismissNavigation = { [weak self] in
                self?.startNavigationTask?.cancel()
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

            startNavigationTask = Task {
                try? await self.waitForFirstLocation()

                guard !Task.isCancelled else {
                    return
                }

                do {
                    try navigationSdk.startNavigation(
                        routable: routable,
                        vehicleConfig: vehicleConfig,
                        routeOptions: routeOptions
                    )
                } catch {
                    navigationViewModel.onStartNavigationFailed(with: error)
                }

                initiallyStarted = true
            }

            displayDimmingController.disableAutomaticDimmming()
        }

        override public func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)

            guard !navigationSdk.navigationActive, initiallyStarted else {
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

            locationProvider.stopLocationUpdates()
            locationProvider.removeLocationUpdateListener(locationUpdateListener: self)
        }

        // MARK: Functions

        func toggleVoiceInstructionComponent() {
            voiceInstructionComponent.enabled.toggle()
        }

        private func waitForFirstLocation() async throws {
            for _ in 0 ..< 25 {
                if navigationSdk.location != nil {
                    return
                }
                try await Task.sleep(seconds: 0.1)
            }
        }
    }
}

extension NavigationScreen.ViewController: LocationProviderLocationUpdateListener {
    public func onLocationUpdated(location: Location) {
        navigationSdk.updateLocation(location: location)
    }
}
