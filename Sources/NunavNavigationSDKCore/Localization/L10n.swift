enum L10n {
    // MARK: Static Properties

    static let routeProgressViewUnitKilometersAbbreviation = String(
        localized: "route_progress_view_unit_kilometers_abbreviation",
        bundle: .module
    )

    static let routeProgressViewUnitMetersAbbreviation = String(
        localized: "route_progress_view_unit_meters_abbreviation",
        bundle: .module
    )

    static let routeProgressViewUnitMilesAbbreviation = String(
        localized: "route_progress_view_unit_miles_abbreviation",
        bundle: .module
    )

    static let routeProgressViewUnitFeetAbbreviation = String(
        localized: "route_progress_view_unit_feet_abbreviation",
        bundle: .module
    )

    static let routeProgressViewUnitDaysAbbreviation = String(
        localized: "route_progress_view_unit_days_abbreviation",
        bundle: .module
    )

    static let routeProgressViewUnitHoursAbbreviation = String(
        localized: "route_progress_view_unit_hours_abbreviation",
        bundle: .module
    )

    static let routeProgressViewUnitMinutesAbbreviation = String(
        localized: "route_progress_view_unit_minutes_abbreviation",
        bundle: .module
    )

    static let routeProgressViewUnitSecondsAbbreviation = String(
        localized: "route_progress_view_unit_seconds_abbreviation",
        bundle: .module
    )

    static let routeProgressViewDayPeriodAMAbbreviation = String(
        localized: "route_progress_view_day_period_am_abbreviation",
        bundle: .module
    )

    static let routeProgressViewDayPeriodPMAbbreviation = String(
        localized: "route_progress_view_day_period_pm_abbreviation",
        bundle: .module
    )

    static let routeProgressViewUnitOClock = String(
        localized: "route_progress_view_unit_o_clock",
        bundle: .module
    )

    static let routeProgressViewDialogDestinationReachedTitle = String(
        localized: "route_progress_view_dialog_destination_reached_title",
        bundle: .module
    )

    static let routeProgressViewDialogEndNavigationTitle = String(
        localized: "route_progress_view_dialog_end_navigation_title",
        bundle: .module
    )

    static let routeProgressViewDialogEndNavigationSummary = String(
        localized: "route_progress_view_dialog_end_navigation_summary",
        bundle: .module
    )

    static let maneuverProgressViewLoadingDetachedTitle = String(
        localized: "maneuver_progress_view_loading_detached_title",
        bundle: .module
    )

    static let maneuverProgressViewLoadingInitialRouteTitle = String(
        localized: "maneuver_progress_view_loading_initial_route_title",
        bundle: .module
    )

    static let maneuverProgressViewInternetMissingError = String(
        localized: "maneuver_progress_view_internet_missing_error",
        bundle: .module
    )

    static let contributionDialogTitle = String(
        localized: "contribution_dialog_title",
        bundle: .module
    )

    static let contributionDialogMaptilerActionTitle = String(
        localized: "contribution_dialog_maptiler_action_title",
        bundle: .module
    )

    static let contributionDialogOpenstreetmapActionTitle = String(
        localized: "contribution_dialog_openstreetmap_action_title",
        bundle: .module
    )

    static let contributionDialogNunavActionTitle = String(
        localized: "contribution_dialog_nunav_action_title",
        bundle: .module
    )

    static let navigationErrorNoRouteFoundSummary = String(
        localized: "navigation_error_no_route_found_summary",
        bundle: .module
    )

    static let navigationErrorUnauthorizedSummary = String(
        localized: "navigation_error_unauthorized_summary",
        bundle: .module
    )

    static let navigationErrorTooManyRequestsSummary = String(
        localized: "navigation_error_too_many_requests_summary",
        bundle: .module
    )

    static let navigationErrorServiceTemporarilyUnavailableSummary = String(
        localized: "navigation_error_service_temporarily_unavailable_summary",
        bundle: .module
    )

    static let navigationErrorMethodNotAllowedSummary = String(
        localized: "navigation_error_method_not_allowed_summary",
        bundle: .module
    )

    static let navigationErrorNoLocationAvailableSummary = String(
        localized: "navigation_error_no_location_available_summary",
        bundle: .module
    )

    static let mapOverlayBackToRouteButtonTitle = String(
        localized: "map_overlay_back_to_route_button_title",
        bundle: .module
    )

    // MARK: Static Functions

    static func maneuverProgressViewFollowingManeuverText(_ text: String) -> String {
        String(
            format: String(localized: "maneuver_progress_view_following_maneuver_text", bundle: .module),
            text
        )
    }
}
