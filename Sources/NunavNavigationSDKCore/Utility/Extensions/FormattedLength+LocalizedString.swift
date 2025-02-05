import Foundation
import MultiplatformNavigation

extension FormattedLength {
    static func localizedString(for length: FormattedLength) -> String {
        return "\(length.value) \(localizedString(for: length.unit))"
    }

    static func localizedString(for unit: FormattedLength.Unit) -> String {
        switch unit {
        case .kilometers:
            L10n.routeProgressViewUnitKilometersAbbreviation
        case .meters:
            L10n.routeProgressViewUnitMetersAbbreviation
        case .miles:
            L10n.routeProgressViewUnitMilesAbbreviation
        case .feet:
            L10n.routeProgressViewUnitFeetAbbreviation
        }
    }
}
