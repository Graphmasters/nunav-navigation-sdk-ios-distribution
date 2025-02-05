import Foundation
import MultiplatformNavigation

extension FormattedDuration {
    static func localizedString(for length: FormattedDuration) -> String {
        return "\(length.value) \(localizedString(for: length.unit))"
    }

    static func localizedString(for unit: FormattedDuration.Unit) -> String {
        switch unit {
        case .day:
            return L10n.routeProgressViewUnitDaysAbbreviation
        case .hour:
            return L10n.routeProgressViewUnitHoursAbbreviation
        case .minute:
            return L10n.routeProgressViewUnitMinutesAbbreviation
        case .second:
            return L10n.routeProgressViewUnitSecondsAbbreviation
        }
    }
}
