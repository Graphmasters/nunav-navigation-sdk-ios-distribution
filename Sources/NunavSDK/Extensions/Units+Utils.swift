import CoreLocation
import NunavSDKMultiplatform

extension LatLng {
    // MARK: Computed Properties

    public var clLocationCoordinate2D: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    // MARK: Lifecycle

    public convenience init(clCoordinate: CLLocationCoordinate2D) {
        self.init(latitude: clCoordinate.latitude, longitude: clCoordinate.longitude)
    }
}

extension LatLng {
    public var formattedDescription: String {
        String(format: "%.02f, %.02f", latitude, longitude)
    }
}

extension Location {
    public convenience init(
        provider: String = "UNKNWON",
        latLng: LatLng,
        altitude: Length? = nil,
        heading: Double? = nil,
        speed: Speed? = nil,
        accuracy: Length? = nil,
        level: Int? = nil
    ) {
        self.init(
            provider: provider,
            timestamp: Timestamp.now().wholeMilliseconds(),
            latLng: latLng,
            altitude: altitude,
            heading: heading.map { KotlinDouble(value: $0) },
            speed: speed,
            accuracy: accuracy,
            level: level.map { KotlinInt(int: Int32($0)) }
        )
    }
}

extension Timestamp {
    public static func now() -> Timestamp {
        Timestamp.companion.fromMilliseconds(
            milliseconds: Time.shared.currentTimeMs
        )
    }
}
