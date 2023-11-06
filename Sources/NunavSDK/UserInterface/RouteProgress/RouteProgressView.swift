import Foundation
import NunavDesignSystem
import NunavSDKMultiplatform
import SwiftUI

struct RouteProgressView: View {
    private var landscapeMode: Bool = false
    private var viewModel: RouteProgressViewModel
    private let geometryProxy: GeometryProxy

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

    @State private var destiantionReachedShown = false
    @State private var endNavigationShown = false

    init(viewModel: RouteProgressViewModel, geometryProxy: GeometryProxy, landscapeMode: Bool) {
        self.landscapeMode = landscapeMode
        self.viewModel = viewModel
        self.geometryProxy = geometryProxy
        _state = State(initialValue: viewModel.state.value)
    }

    var body: some View {
        HStack {
            VStack {
                ZStack {
                    Color.DesignSystem.surfacePrimary.cornerRadius(
                        Size.BottomSheet.cornerRadius,
                        corners: [.topLeft, .topRight]
                    ).edgesIgnoringSafeArea(
                        landscapeMode ? [.trailing, .bottom] : [.leading, .trailing, .bottom]
                    )

                    HStack(spacing: .zero) {
                        HStack(spacing: .zero) {
                            switch onEnum(of: state) {
                            case let .followingRoute(followingRoute):
                                let formatedRouteProgress = RouteProgressUIStateFormatter.shared
                                    .convert(routeProgressUIState: followingRoute)
                                RouteProgressDataView(
                                    durationValue: formatedRouteProgress.duration.value,
                                    durationUnit: formatedRouteProgress.duration.unit == .hour
                                        ? L10n.routeProgressViewUnitHoursAbbreviation
                                        : L10n.routeProgressViewUnitMinutesAbbreviation,
                                    etaValue: formatedRouteProgress.timestampConverter.value,
                                    etaUnit: formatedRouteProgress.timestampConverter.unit
                                        ?? L10n.routeProgressViewUnitOClock,
                                    distanceValue: formatedRouteProgress.distance.value,
                                    distanceUnit: formatedRouteProgress.distance.unit
                                )
                            case .loading:
                                RouteProgressDataView()
                                    .redacted(reason: .placeholder)
                            }
                        }
                        Spacer()
                        DestructiveButton(image: UIImage(systemName: "xmark")!, wrapsContent: true, iconHeight: 24) {
                            self.endNavigationShown = true
                        }.layoutPriority(1)
                    }.padding(.horizontal, Size.Padding.large)
                        .padding(.top)
                        .padding(.bottom, max(.zero, Size.Padding.default - geometryProxy.safeAreaInsets.bottom))
                        .layoutPriority(1)
                }
            }
        }.onAppear {
            state = viewModel.state.value
            Task {
                for await state in viewModel.state {
                    self.state = state
                }
            }
        }.alert(
            L10n.routeProgressViewDialogDestinationReachedTitle,
            isPresented: $destiantionReachedShown,
            actions: {
                Button(L10n.routeProgressViewDialogActionYes, role: .none) {
                    NunavSDK.navigationSdk.stopNavigation()
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
                    NunavSDK.navigationSdk.stopNavigation()
                }
                Button(L10n.routeProgressViewDialogActionNo, role: .cancel, action: {})
            }, message: {
                Text(L10n.routeProgressViewDialogEndNavigationSummary)
            }
        )
    }
}

struct RouteProgressDataView: View {
    private let durationValue: String
    private let durationUnit: String

    private let etaValue: String
    private let etaUnit: String

    private let distanceValue: String
    private let distanceUnit: String

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

    var body: some View {
        HStack(spacing: Size.Padding.large * 2) {
            MetadataView(
                value: durationValue,
                unit: durationUnit
            )
            MetadataView(
                value: etaValue,
                unit: etaUnit
            )
            MetadataView(
                value: distanceValue,
                unit: distanceUnit
            )
        }
    }
}

private struct MetadataView: View {
    let value: String
    let unit: String

    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            ZStack(alignment: .leading) {
                if value.contains(".") || value.contains(":") {
                    Text(Array(repeating: "8", count: min(value.count, 4) - 1).joined() + ".")
                        .font(.DesignSystem.Headline.default)
                        .opacity(0)
                } else {
                    Text(Array(repeating: "8", count: min(value.count, 3)).joined())
                        .font(.DesignSystem.Headline.default)
                        .opacity(0)
                }
                Text(value)
                    .font(.DesignSystem.Headline.default)
                    .foregroundColor(.DesignSystem.onSurfacePrimary)
            }
            Text(unit)
                .font(.DesignSystem.Body.small)
                .foregroundColor(.DesignSystem.onSurfaceSecondary)
        }
    }
}
