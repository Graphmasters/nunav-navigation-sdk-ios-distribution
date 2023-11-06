import Foundation
import NunavSDKMultiplatform

public extension DurationConverterResult {
    func formattedString() -> String {
        [value, unit].joined(separator: " ")
    }
}

public extension Array where Element == DurationConverterResult {
    func formattedString() -> String {
        map { $0.formattedString() }.joined(separator: " ")
    }
}
