import Foundation
import NunavSDKMultiplatform

extension DistanceConverterResult {
    public func formattedString() -> String {
        return "\(value) \(unit)"
    }
}

extension DistanceConverter {
    public func convert(length: Length) -> DistanceConverterResult {
        let result = convert(
            length: length,
            measurementSystem: LocaleMeasurementSystemProvider(
                locale: .autoupdatingCurrent
            ).getMeasurementSystem()
        )
        return result
    }
}
