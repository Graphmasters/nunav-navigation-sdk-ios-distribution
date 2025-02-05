import CoreLocation
import Foundation
import GMCoreUtility
import MultiplatformNavigation
import UIKit

/// The main class to interact with the Nunav Navigation SDK. This class is used for configuring the SDK and accessing the navigation options.
public enum NunavNavigationSDK {
    // MARK: Static Properties

    static let navigationSdk: NavigationSdk = {
        guard let apiKey = apiKey, let serviceUrl = serviceUrl else {
            fatalError(
                """
                To use `NunavNavigationSDK` an api key and a service url are needed. Please use
                `NunavNavigationSDK.configure(apiKey: String, serviceUrl: String)` first.
                """
            )
        }
        return IosNavigationSdk(
            serviceUrl: serviceUrl + "/v2/routing/",
            apiKey: apiKey,
            sessionParamProviders: [],
            routingParamProviders: [],
            instanceId: instanceId
        )
    }()

    static let locationProvider: LocationProvider = CLLocationProvider(locationManager: locationManager)

    static let locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.activityType = .automotiveNavigation
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = false
        manager.headingFilter = kCLHeadingFilterNone
        manager.distanceFilter = kCLDistanceFilterNone
        return manager
    }()

    private static var apiKey: String?
    private static var serviceUrl: String?
    private static var instanceId: String = Device.info.deviceId

    // MARK: Static Functions

    /// Configures the SDK with the given API key and service URL.
    ///
    /// - parameters:
    ///    - apiKey: The API key to use for the SDK. See <doc:GettingStarted> to learn more.
    ///    - serviceUrl: The URL of the service to use for the SDK. If you need any custom routing configurations, you can [contact
    ///         us](https://nunav.net/lp/sdk) to get a custom service URL with customized routing. Setting a service URL is optional.
    /// - warning: This function should be called before using the SDK. Otherwise a fatal error will be thrown when instantiating UI.
    public static func configure(
        apiKey: String,
        serviceUrl: String = "https://nunav-sdk-bff.nunav.net"
    ) {
        guard Self.apiKey == nil else {
            fatalError("`NunavSDK` was already configured.")
        }
        Self.apiKey = apiKey
        Self.serviceUrl = serviceUrl
    }
}
