import CoreLocation
import Foundation
import NunavSDKMultiplatform
import UIKit

enum NavigationUIError: Error {
    case missingLocationAuthorization
}

public enum NavigationUI {
    public static func makeNavigationUI(
        destinationCoordinate: CLLocationCoordinate2D,
        destinationLabel: String? = nil
    ) throws -> UIViewController {
        guard hasAuthorization() else {
            throw NavigationUIError.missingLocationAuthorization
        }
        return NavigationScreenViewController(
            destination: destination(destinationCoordinate: destinationCoordinate, destinationLabel: destinationLabel),
            navigationSdk: NunavSDK.navigationSdk,
            routeDetachStateProvider: routeDetachStateProvider
        )
    }

    private static func hasAuthorization() -> Bool {
        return NunavSDK.locationManager.authorizationStatus == .authorizedWhenInUse
            && NunavSDK.locationManager.accuracyAuthorization == .fullAccuracy
    }

    static let mapLocationProvider: LocationProvider = PredictedLocationProvider(
        executor: OperationQueueExecutor(),
        navigationSdk: NunavSDK.navigationSdk,
        routeDetachStateProvider: NavigationUI.routeDetachStateProvider
    )

    private static func destination(
        destinationCoordinate: CLLocationCoordinate2D,
        destinationLabel: String?
    ) -> Routable {
        let latLng = LatLng(latitude: destinationCoordinate.latitude, longitude: destinationCoordinate.longitude)
        return if let label = destinationLabel {
            RoutableFactory.shared.create(
                latLng: latLng,
                label: label
            )
        } else {
            RoutableFactory.shared.create(latLng: latLng)
        }
    }

    static let routeDetachStateProvider: RouteDetachStateProvider
        = OffRouteDetachStateProvider(navigationSdk: NunavSDK.navigationSdk)

    static let voiceInstructionComponent = VoiceInstructionComponent(
        navigationSdk: NunavSDK.navigationSdk,
        routeDetachStateProvider: routeDetachStateProvider
    )
}
