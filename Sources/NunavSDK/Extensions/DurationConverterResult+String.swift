import Foundation
import NunavSDKMultiplatform

extension DurationConverterResult {
    public func formattedString() -> String {
        [value, unit].joined(separator: " ")
    }
}

extension Array where Element == DurationConverterResult {
    public func formattedString() -> String {
        map { $0.formattedString() }.joined(separator: " ")
    }
}
