import CoreLocation

/// A struct that represents a destination configuration for the navigation.
public struct DestinationConfiguration {
    // MARK: Properties

    /// An optional identifier for the destination. If this is an identifier known by the backend, special routing
    /// configurations can be provided by the service for specific destinations.
    public let id: String?
    /// The coordinate of the destination.
    public let coordinate: CLLocationCoordinate2D
    /// A display name for the destination. Will be displayed at the end of the navigation.
    public let label: String?

    // MARK: Lifecycle

    /// Initializes a new `DestinationConfiguration` with the provided parameters.
    public init(
        id: String? = nil,
        coordinate: CLLocationCoordinate2D,
        label: String? = nil
    ) {
        self.id = id ?? "\(coordinate.latitude)_\(coordinate.longitude)"
        self.coordinate = coordinate
        self.label = label
    }
}
