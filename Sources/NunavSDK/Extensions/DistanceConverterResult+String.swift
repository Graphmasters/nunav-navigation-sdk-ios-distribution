import Foundation
import NunavSDKMultiplatform

public extension DistanceConverterResult {
    func formattedString() -> String {
        return "\(value) \(unit)"
    }
}

public extension DistanceConverter {
    func convert(length: Length) -> DistanceConverterResult {
        let result = convert(
            length: length,
            measurementSystem: LocaleMeasurementSystemProvider(
                locale: .autoupdatingCurrent
            ).getMeasurementSystem()
        )
        return result
    }
}
