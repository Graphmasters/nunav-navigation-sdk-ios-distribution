import Foundation
import NunavDesignSystem
import NunavSDKMultiplatform
import SwiftUI

struct RouteProgressView: View {
    // MARK: Properties

    private var landscapeMode: Bool = false
    private var viewModel: RouteProgressViewModel
    private let geometryProxy: GeometryProxy

    @State private var destiantionReachedShown = false
    @State private var endNavigationShown = false

    // MARK: Computed Properties

    @State private var state: RouteProgressUIState {
        didSet {
            guard let followingRoute = state.asFollowingRoute,
                  oldValue.asFollowingRoute?.destinationReached != followingRoute.destinationReached,
                  followingRoute.destinationReached else {
                return
            }
            destiantionReachedShown = true
        }
    }

    // MARK: Lifecycle

    init(viewModel: RouteProgressViewModel, geometryProxy: GeometryProxy, landscapeMode: Bool) {
        self.landscapeMode = landscapeMode
        self.viewModel = viewModel
        self.geometryProxy = geometryProxy
        _state = State(initialValue: viewModel.state.value)
    }

    // MARK: Content

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
                            switch onEnum(of: self.state) {
                            case let .followingRoute(followingRoute):
                                let formattedRouteProgress = RouteProgressUIStateFormatter.shared
                                    .convert(routeProgressUIState: followingRoute)
                                RouteProgressDataView(
                                    durationValue: formattedRouteProgress.duration.value,
                                    durationUnit: formattedRouteProgress.duration.unit == .hour
                                        ? L10n.routeProgressViewUnitHoursAbbreviation
                                        : L10n.routeProgressViewUnitMinutesAbbreviation,
                                    etaValue: formattedRouteProgress.timestampConverter.value,
                                    etaUnit: formattedRouteProgress.timestampConverter.unit
                                        ?? L10n.routeProgressViewUnitOClock,
                                    distanceValue: formattedRouteProgress.distance.value,
                                    distanceUnit: formattedRouteProgress.distance.unit
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
                            sizing: .intrinsic
                        ) {
                            self.endNavigationShown = true
                        }.layoutPriority(1)
                    }.padding(.horizontal, Spacing.large.rawValue)
                        .padding(.top)
                        .padding(.bottom, max(.zero, Spacing.default.rawValue - self.geometryProxy.safeAreaInsets.bottom))
                        .layoutPriority(1)
                }
            }
        }.onAppear {
            self.state = self.viewModel.state.value
            Task {
                for await state in self.viewModel.state {
                    self.state = state
                }
            }
        }.alert(
            L10n.routeProgressViewDialogDestinationReachedTitle,
            isPresented: $destiantionReachedShown,
            actions: {
                Button(L10n.routeProgressViewDialogActionYes, role: .none) {
                    DispatchQueue.global(qos: .background).async {
                        NunavSDK.navigationSdk.stopNavigation()
                    }
                }
                Button(L10n.routeProgressViewDialogActionNo, role: .cancel, action: {})
            }, message: {
                Text(L10n.routeProgressViewDialogEndNavigationSummary)
            }
        ).alert(
            L10n.routeProgressViewDialogEndNavigationTitle,
            isPresented: $endNavigationShown,
            actions: {
                Button(L10n.routeProgressViewDialogActionYes, role: .none) {
                    DispatchQueue.global(qos: .background).async {
                        NunavSDK.navigationSdk.stopNavigation()
                    }
                }
                Button(L10n.routeProgressViewDialogActionNo, role: .cancel, action: {})
            }, message: {
                Text(L10n.routeProgressViewDialogEndNavigationSummary)
            }
        )
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

    // MARK: Content

    var body: some View {
        HStack(spacing: Spacing.large.rawValue * 2) {
            MetadataView(
                value: self.durationValue,
                unit: self.durationUnit
            )
            MetadataView(
                value: self.etaValue,
                unit: self.etaUnit
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

    // MARK: Content

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
