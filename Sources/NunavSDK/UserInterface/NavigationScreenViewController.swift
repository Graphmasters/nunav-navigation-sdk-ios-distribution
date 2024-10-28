import CoreLocation
import Foundation
import GMCoreUtility
import NunavSDKMultiplatform
import SwiftUI
import UIKit

class NavigationScreenViewController: UIHostingController<NavigationScreen> {
    // MARK: Nested Types

    private final class NavigationStopUseCase: NavigationEventHandlerOnNavigationStoppedListener {
        // MARK: Properties

        private let closeViewController: () -> Void

        // MARK: Lifecycle

        init(closeViewController: @escaping () -> Void) {
            self.closeViewController = closeViewController
        }

        // MARK: Functions

        func onNavigationStopped() {
            closeViewController()
        }
    }

    // MARK: Properties

    private let destination: Routable
    private let navigationSdk: NavigationSdk

    private let navigationViewModel: NavigationViewModel
    private let routeProgressViewModel: RouteProgressViewModel
    private let maneuverViewModel: ManeuverViewModel

    private var navigationStopUseCase: NavigationStopUseCase!

    private let displayDimmingController = DisplayDimmingController()

    // MARK: Lifecycle

    init(
        destination: Routable,
        navigationSdk: NavigationSdk,
        routeDetachStateProvider: RouteDetachStateProvider
    ) {
        self.destination = destination
        self.navigationSdk = navigationSdk

        let navigationViewModel = NavigationViewModel(
            navigationSdk: navigationSdk, locationProvider: NavigationUI.mapLocationProvider
        )

        let routeProgressViewModel = RouteProgressViewModel(
            navigationSdk: navigationSdk,
            routeDetachStateProvider: routeDetachStateProvider,
            routeProgressUIStateConverter: RouteProgressUIStateConverter()
        )

        let maneuverViewModel = ManeuverViewModel(
            navigationSdk: navigationSdk,
            detachStateProvider: NavigationUI.routeDetachStateProvider,
            maneuverUIStateConverter: ManeuverUIStateConverter()
        )

        self.navigationViewModel = navigationViewModel
        self.routeProgressViewModel = routeProgressViewModel
        self.maneuverViewModel = maneuverViewModel

        super.init(
            rootView: NavigationScreen(
                navigationViewModel: navigationViewModel,
                routeProgressViewModel: routeProgressViewModel,
                maneuverViewModel: maneuverViewModel
            )
        )

        isModalInPresentation = true
        modalPresentationStyle = .fullScreen

        self.navigationStopUseCase = NavigationStopUseCase(
            closeViewController: { [weak self] in
                self?.dismiss(animated: true)
            }
        )
    }

    @available(*, unavailable)
    @MainActor dynamic required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Overridden Functions

    override func viewDidLoad() {
        super.viewDidLoad()

        NunavSDK.locationProvider.addLocationUpdateListener(locationUpdateListener: self)
        NunavSDK.locationProvider.startLocationUpdates()
        NunavSDK.locationProvider.lastKnownLocation.map {
            NunavSDK.navigationSdk.updateLocation(location: $0)
        }

        NavigationUI.voiceInstructionComponent.enabled = true

        CLLocationManager().requestWhenInUseAuthorization()

        try? navigationSdk.startNavigation(routable: destination, routeOptions: .init(avoidTollRoads: false))

        displayDimmingController.disableAutomaticDimmming()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationSdk.addOnNavigationStoppedListener(onNavigationStoppedListener: navigationStopUseCase)

        guard !navigationSdk.navigationActive else {
            return
        }

        displayDimmingController.enableAutomaticDimmming()

        dismiss(animated: true)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        navigationSdk.removeOnNavigationStoppedListener(onNavigationStoppedListener: navigationStopUseCase)

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
