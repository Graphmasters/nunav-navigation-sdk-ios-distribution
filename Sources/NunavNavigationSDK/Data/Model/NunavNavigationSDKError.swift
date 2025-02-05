import Foundation

/// Errors that can be thrown by the NunavNavigationSDK.
public enum NunavNavigationSDKError: LocalizedError {
    /// Thrown when the user has not granted location permissions to the app before initializing the navigation user interface.
    case missingLocationAuthorization

    // MARK: Computed Properties

    public var errorDescription: String? {
        switch self {
        case .missingLocationAuthorization:
            return L10n.navigationErrorMissingLocationPermissionTitle
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .missingLocationAuthorization:
            return L10n.navigationErrorMissingLocationPermissionSummary
        }
    }
}
