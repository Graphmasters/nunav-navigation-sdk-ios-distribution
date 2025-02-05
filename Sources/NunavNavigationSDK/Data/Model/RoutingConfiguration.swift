/// The `RoutingConfiguration` struct is used to configure a routing session. It defines
///  different factors that influence resulting routes.
public struct RoutingConfiguration {
    // MARK: Properties

    /// The transport mode you expect the user to use. The navigation will route the navigation
    /// accordingly to the restrictions of the chosen transport mode.
    public let transportMode: TransportMode
    /// If true only toll free roads will be considered for the navigation routing.
    public let avoidTollRoads: Bool
    /// The context token is used to provide additional information to the routing service. This
    /// can add additional context for guiding users individually to their destination. E.g. this might guide them to specific parking spots.
    public let contextToken: String?

    // MARK: Lifecycle

    /// Initializes a new ``RoutingConfiguration``.
    public init(
        transportMode: TransportMode,
        avoidTollRoads: Bool,
        contextToken: String?
    ) {
        self.transportMode = transportMode
        self.contextToken = contextToken
        self.avoidTollRoads = avoidTollRoads
    }
}
