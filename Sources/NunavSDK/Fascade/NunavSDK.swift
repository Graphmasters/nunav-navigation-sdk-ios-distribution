import CoreLocation
import Foundation
import GMCoreUtility
import NunavSDKMultiplatform
import UIKit

public enum NunavSDK {
    // MARK: Static Properties

    static let navigationSdk: NavigationSdk = {
        guard let apiKey = apiKey, let serviceUrl = serviceUrl else {
            fatalError(
                """
                To use `NunavSDK` an api key and a service url are needed. Please use
                `NunavSDK.configure(apiKey: String, serviceUrl: String)` first.
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

    public static func configure(apiKey: String, serviceUrl: String = "https://nunav-sdk-bff.nunav.net") {
        guard Self.apiKey == nil else {
            fatalError("`NunavSDK` was already configured.")
        }
        Self.apiKey = apiKey
        Self.serviceUrl = serviceUrl
    }
}
