import CoreLocation
import NunavSDKMultiplatform

public extension LatLng {
    convenience init(clCoordinate: CLLocationCoordinate2D) {
        self.init(latitude: clCoordinate.latitude, longitude: clCoordinate.longitude)
    }

    var clLocationCoordinate2D: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

public extension LatLng {
    var formattedDescription: String {
        String(format: "%.02f, %.02f", latitude, longitude)
    }
}

public extension Location {
    convenience init(
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

extension NunavSDKMultiplatform.Duration: Comparable {
    public static func < (lhs: Duration, rhs: Duration) -> Bool {
        lhs.inWholeMilliseconds() < rhs.inWholeMilliseconds()
    }

    public static func + (lhs: Duration, rhs: Duration) -> Duration {
        lhs.plus(other: rhs)
    }

    public static func - (lhs: Duration, rhs: Duration) -> Duration {
        lhs.minus(other: rhs)
    }
}

extension Length: Comparable {
    public static func < (lhs: Length, rhs: Length) -> Bool { lhs.inMeters() < rhs.inMeters() }

    public static func + (lhs: Length, rhs: Length) -> Length { lhs.plus(other: rhs) }

    public static func - (lhs: Length, rhs: Length) -> Length { lhs.minus(other: rhs) }

    public static func * (lhs: Length, rhs: Double) -> Length {
        Length.companion.fromMeters(meters: lhs.inMeters() * rhs)
    }
}

extension Speed: Comparable {
    public static func < (lhs: Speed, rhs: Speed) -> Bool { lhs.inMs() < rhs.inMs() }
}

public extension Timestamp {
    static func now() -> Timestamp {
        Timestamp.companion.fromMilliseconds(
            milliseconds: Time.shared.currentTimeMs
        )
    }
}
