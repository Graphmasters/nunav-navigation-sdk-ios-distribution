import Foundation
import MultiplatformNavigation
import NunavDesignSystem
import SwiftUI

struct RouteProgressView: View {
    // MARK: SwiftUI Properties

    @ObservedObject private var viewModel: RouteProgressViewModel

    // MARK: Properties

    private var landscapeMode: Bool = false
    private let geometryProxy: GeometryProxy
    private let onStopNavigationButtonTapped: () -> Void

    // MARK: Lifecycle

    init(
        viewModel: RouteProgressViewModel,
        geometryProxy: GeometryProxy,
        landscapeMode: Bool,
        onStopNavigationButtonTapped: @escaping () -> Void
    ) {
        self.landscapeMode = landscapeMode
        self.viewModel = viewModel
        self.geometryProxy = geometryProxy
        self.onStopNavigationButtonTapped = onStopNavigationButtonTapped
    }

    // MARK: Content Properties

    var body: some View {
        HStack {
            VStack {
                ZStack {
                    Color.DesignSystem.surfacePrimary
                        .cornerRadius(corners: [.topLeft, .topRight], .default)
                        .edgesIgnoringSafeArea(
                            self.landscapeMode ? [.trailing, .bottom] : [.leading, .trailing, .bottom]
                        )

                    HStack(spacing: .zero) {
                        HStack(spacing: .zero) {
                            switch onEnum(of: self.viewModel.state) {
                            case let .followingRoute(followingRoute):
                                RouteProgressDataView(
                                    durationValue: followingRoute.formattedDuration.value,
                                    durationUnit: FormattedDuration.localizedString(
                                        for: followingRoute.formattedDuration.unit
                                    ),
                                    etaValue: followingRoute.formattedTimestamp.value,
                                    etaUnit: followingRoute.formattedTimestamp.dayPeriod.map {
                                        FormattedTimestamp.localizedString(for: $0)
                                    } ?? L10n.routeProgressViewUnitOClock,
                                    distanceValue: followingRoute.formattedLength.value,
                                    distanceUnit: FormattedLength.localizedString(
                                        for: followingRoute.formattedLength.unit
                                    )
                                )
                            case .loading:
                                RouteProgressDataView()
                                    .redacted(reason: .placeholder)
                            }
                        }
                        Spacer()
                        FilledButton(
                            icon: .icXMark,
                            style: .destructive,
                            sizing: .intrinsic,
                            action: onStopNavigationButtonTapped
                        ).layoutPriority(1)
                    }.padding(.horizontal, Spacing.large.rawValue)
                        .padding(.top)
                        .padding(.bottom, max(.zero, Spacing.default.rawValue - self.geometryProxy.safeAreaInsets.bottom))
                        .layoutPriority(1)
                }
            }
        }
    }
}

struct RouteProgressDataView: View {
    // MARK: Properties

    private let durationValue: String
    private let durationUnit: String

    private let etaValue: String
    private let etaUnit: String

    private let distanceValue: String
    private let distanceUnit: String

    // MARK: Lifecycle

    init(
        durationValue: String = "-:--",
        durationUnit: String = L10n.routeProgressViewUnitMinutesAbbreviation,
        etaValue: String = "-:--",
        etaUnit: String = L10n.routeProgressViewUnitOClock,
        distanceValue: String = "--,-",
        distanceUnit: String = "--"
    ) {
        self.durationValue = durationValue
        self.durationUnit = durationUnit
        self.etaValue = etaValue
        self.etaUnit = etaUnit
        self.distanceValue = distanceValue
        self.distanceUnit = distanceUnit
    }

    // MARK: Content Properties

    var body: some View {
        HStack(spacing: Spacing.large.rawValue * 2) {
            MetadataView(
                value: self.etaValue,
                unit: self.etaUnit
            )
            MetadataView(
                value: self.durationValue,
                unit: self.durationUnit
            )
            MetadataView(
                value: self.distanceValue,
                unit: self.distanceUnit
            )
        }
    }
}

private struct MetadataView: View {
    // MARK: Properties

    let value: String
    let unit: String

    // MARK: Content Properties

    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            ZStack(alignment: .leading) {
                if self.value.contains(".") || self.value.contains(":") {
                    Text(Array(repeating: "8", count: min(self.value.count, 4) - 1).joined() + ".")
                        .font(.DesignSystem.Headline.default)
                        .opacity(0)
                } else {
                    Text(Array(repeating: "8", count: min(self.value.count, 3)).joined())
                        .font(.DesignSystem.Headline.default)
                        .opacity(0)
                }
                Text(self.value)
                    .font(.DesignSystem.Headline.default)
                    .foregroundColor(.DesignSystem.onSurfacePrimary)
            }
            Text(self.unit)
                .font(.DesignSystem.Body.small)
                .foregroundColor(.DesignSystem.onSurfaceSecondary)
        }
    }
}
