/// Defines different modes of transport for navigation, each with its own constraints and routing
/// rules. These modes influence route calculation, taking into account road access, speed limits,
/// and restrictions of the specified transport mode.
public enum TransportMode: String, CaseIterable, Identifiable {
    /// Allows navigation through bike paths and prohibits navigation on large roads.
    case bicycle = "Bicycle"
    /// Takes special challenges for busses like height restrictions and specific road classes into
    /// account. Assume speeds according to local laws for busses.
    case bus = "Bus"
    /// Assumes standard passenger vehicles. Considers general road laws and speed limits applicable
    /// to cars. Avoids restricted roads like pedestrian zones or roads prohibited for cars.
    case car = "Car"
    /// Allows navigation on footpaths and prohibits navigation along roads not meant for
    /// pedestrians.
    case pedestrian = "Pedestrian"
    /// Assumes large or heavy vehicles and doesn't navigate through places with weight
    /// or height restrictions. Assumes speeds according to local laws for trucks.
    case truck = "Truck"

    public var id: String { self.rawValue }
}
