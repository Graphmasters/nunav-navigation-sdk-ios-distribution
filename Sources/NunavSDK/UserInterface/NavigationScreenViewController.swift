import CoreLocation
import Foundation
import GMCoreUtility
import NunavSDKMultiplatform
import SwiftUI
import UIKit

class NavigationScreenViewController: UIHostingController<NavigationScreen> {
    private let destination: Routable
    private let navigationSdk: NavigationSdk

    private let displayDimmingController = DisplayDimmingController()

    init(
        destination: Routable,
        navigationSdk: NavigationSdk,
        routeDetachStateProvider: RouteDetachStateProvider
    ) {
        self.destination = destination
        self.navigationSdk = navigationSdk

        super.init(
            rootView: NavigationScreen(
                navigationViewModel: NavigationViewModel(
                    navigationSdk: navigationSdk, locationProvider: NavigationUI.mapLocationProvider
                ), routeProgressViewModel: RouteProgressViewModel(
                    navigationSdk: navigationSdk,
                    routeDetachStateProvider: routeDetachStateProvider,
                    routeProgressUIStateConverter: RouteProgressUIStateConverter()
                ), maneuverViewModel: ManeuverViewModel(
                    navigationSdk: navigationSdk,
                    detachStateProvider: NavigationUI.routeDetachStateProvider,
                    maneuverUIStateConverter: ManeuverUIStateConverter()
                )
            )
        )

        isModalInPresentation = true
        modalPresentationStyle = .fullScreen
    }

    @available(*, unavailable)
    @MainActor dynamic required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NunavSDK.locationProvider.addLocationUpdateListener(locationUpdateListener: self)
        NunavSDK.locationProvider.startLocationUpdates()
        NunavSDK.locationProvider.lastKnownLocation.map {
            NunavSDK.navigationSdk.updateLocation(location: $0)
        }

        NavigationUI.voiceInstructionComponent.enabled = true

        CLLocationManager().requestWhenInUseAuthorization()

        try? navigationSdk.startNavigation(routable: destination)

        displayDimmingController.disableAutomaticDimmming()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationSdk.addOnNavigationStoppedListener(onNavigationStoppedListener: self)

        guard !navigationSdk.navigationActive else {
            return
        }

        displayDimmingController.enableAutomaticDimmming()

        dismiss(animated: true)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        navigationSdk.removeOnNavigationStoppedListener(onNavigationStoppedListener: self)

        guard !navigationSdk.navigationActive else {
            return
        }

        NunavSDK.locationProvider.removeLocationUpdateListener(locationUpdateListener: self)
    }
}

extension NavigationScreenViewController: LocationProviderLocationUpdateListener {
    func onLocationUpdated(location: Location) {
        navigationSdk.updateLocation(location: location)
    }
}

extension NavigationScreenViewController: NavigationEventHandlerOnNavigationStoppedListener {
    func onNavigationStopped() {
        dismiss(animated: true)
    }
}
