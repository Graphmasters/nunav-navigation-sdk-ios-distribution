import CoreLocation
import Foundation
import GMCoreUtility
import NunavSDKMultiplatform
import UIKit

public enum NunavSDK {
    private static var apiKey: String?
    private static var serviceUrl: String?
    private static var instanceId: String = Device.info.deviceId

    public static func configure(apiKey: String, serviceUrl: String) {
        guard Self.apiKey == nil else {
            fatalError("`NunavSDK` was already configured.")
        }
        Self.apiKey = apiKey
        Self.serviceUrl = serviceUrl
    }

    static let navigationSdk: NavigationSdk = {
        guard let apiKey = apiKey else {
            fatalError("To use `NunavSDK` an api key is needed. Please use `NunavSDK.configure(apiKey: String)` first.")
        }
        guard let serviceUrl = serviceUrl else {
            return IosNavigationSdk(apiKey: apiKey)
        }
        return IosNavigationSdk(
            serviceUrl: serviceUrl,
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
}
