import CoreLocation
import Foundation
import MultiplatformNavigation
import NunavNavigationSDKCore
import UIKit

/// The navigation UI component to instantiate the navigation user interface in your app using Nunav SDK.
public enum NunavNavigationUI {
    // MARK: Static Properties

    static let mapLocationProvider: LocationProvider = PredictedLocationProvider(
        navigationSdk: NunavNavigationSDK.navigationSdk
    )

    static let voiceInstructionComponent = VoiceInstructionComponent(
        navigationSdk: NunavNavigationSDK.navigationSdk
    )

    // MARK: Static Functions

    /// Creates a navigation view controller with the given destination and routing configurations.
    ///
    /// - Parameters:
    ///  - destinationConfiguration: The ``DestinationConfiguration`` containing the destination information.
    ///  - routingConfiguration: The ``RoutingConfiguration`` containing the routing information.
    ///  - returns: A navigation view controller.
    ///  - throws: A ``NunavNavigationSDKError`` if the location authorization is missing.
    public static func makeNavigationViewController(
        destinationConfiguration: DestinationConfiguration,
        routingConfiguration: RoutingConfiguration = RoutingConfiguration(
            transportMode: .car,
            avoidTollRoads: false,
            contextToken: nil
        )
    ) throws -> UIViewController {
        guard hasAuthorization() else {
            throw NunavNavigationSDKError.missingLocationAuthorization
        }
        return NavigationScreen.ViewController(
            routable: getDestination(destinationConfiguration: destinationConfiguration),
            vehicleConfig: getVehicleConfiguration(routingConfiguration: routingConfiguration),
            routeOptions: getRouteOptions(routingConfiguration: routingConfiguration),
            navigationSdk: NunavNavigationSDK.navigationSdk,
            mapLocationProvider: mapLocationProvider,
            locationProvider: NunavNavigationSDK.locationProvider,
            voiceInstructionComponent: voiceInstructionComponent
        )
    }

    private static func hasAuthorization() -> Bool {
        return NunavNavigationSDK.locationManager.authorizationStatus == .authorizedWhenInUse
            && NunavNavigationSDK.locationManager.accuracyAuthorization == .fullAccuracy
    }

    private static func getDestination(
        destinationConfiguration: DestinationConfiguration
    ) -> Routable {
        let latLng = LatLng(
            latitude: destinationConfiguration.coordinate.latitude,
            longitude: destinationConfiguration.coordinate.longitude
        )

        return if let label = destinationConfiguration.label,
                  let destinationId = destinationConfiguration.id {
            RoutableFactory.shared.create(
                id: destinationId,
                latLng: latLng,
                label: label
            )
        } else if let label = destinationConfiguration.label {
            RoutableFactory.shared.create(
                latLng: latLng,
                label: label
            )
        } else {
            RoutableFactory.shared.create(latLng: latLng)
        }
    }

    private static func getVehicleConfiguration(
        routingConfiguration: RoutingConfiguration
    ) -> VehicleConfig {
        switch routingConfiguration.transportMode {
        case .bicycle:
            return VehicleConfigTemplates.shared.BICYCLE
        case .bus:
            return VehicleConfigTemplates.shared.BUS
        case .car:
            return VehicleConfigTemplates.shared.CAR
        case .pedestrian:
            return VehicleConfigTemplates.shared.PEDESTRIAN
        case .truck:
            return VehicleConfigTemplates.shared.TRUCK
        }
    }

    private static func getRouteOptions(
        routingConfiguration: RoutingConfiguration
    ) -> RouteOptions {
        .init(
            avoidTollRoads: routingConfiguration.avoidTollRoads,
            contextToken: routingConfiguration.contextToken
        )
    }
}
