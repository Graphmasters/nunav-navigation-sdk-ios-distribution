import MultiplatformNavigation

extension FormattedTimestamp {
    static func localizedString(for timestamp: FormattedTimestamp) -> String {
        return [
            timestamp.value,
            timestamp.dayPeriod.map(localizedString(for:))
        ].compactMap { $0 }.joined(separator: " ")
    }

    static func localizedString(for dayPeriod: FormattedTimestamp.DayPeriod) -> String {
        switch dayPeriod {
        case .am:
            L10n.routeProgressViewDayPeriodAMAbbreviation
        case .pm:
            L10n.routeProgressViewDayPeriodPMAbbreviation
        default:
            ""
        }
    }
}
