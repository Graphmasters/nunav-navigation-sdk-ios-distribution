import Foundation
import MultiplatformNavigation
import Network
import NunavDesignSystem
import SwiftUI

public struct NavigationScreen: View {
    // MARK: Static Properties

    static let internetViewHeight: CGFloat = 74

    // MARK: SwiftUI Properties

    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    @StateObject var navigationViewModel: NavigationScreen.ViewModel

    @StateObject private var routeProgressViewModel: RouteProgressViewModel

    @State private var isNetworkMissing = false

    // MARK: Properties

    let monitor = NWPathMonitor()

    private let mapLocationProvider: LocationProvider
    private let navigationSdk: NavigationSdk
    private let routeDetachStateProvider: RouteDetachStateProvider

    // MARK: Lifecycle

    init(
        navigationViewModel: NavigationScreen.ViewModel,
        routeProgressViewModel: RouteProgressViewModel,
        mapLocationProvider: LocationProvider,
        navigationSdk: NavigationSdk,
        routeDetachStateProvider: RouteDetachStateProvider
    ) {
        self._navigationViewModel = StateObject(wrappedValue: navigationViewModel)
        self._routeProgressViewModel = StateObject(wrappedValue: routeProgressViewModel)

        self.mapLocationProvider = mapLocationProvider
        self.navigationSdk = navigationSdk
        self.routeDetachStateProvider = routeDetachStateProvider
    }

    // MARK: Content Properties

    public var body: some View {
        ZStack {
            MapView(
                onUserInteracted: navigationViewModel.onUserInteracted(interaction:),
                mapLocationProvider: mapLocationProvider,
                navigationSdk: navigationSdk,
                routeDetachStateProvider: routeDetachStateProvider,
                navigationState: $navigationViewModel.state
            )
            .edgesIgnoringSafeArea(.all)
            VStack {
                Color.clear
                    .edgesIgnoringSafeArea([.top, .leading, .trailing])
                    .background(.ultraThinMaterial)
                Spacer()
                    .layoutPriority(1)
            }
            VStack {
                if (self.verticalSizeClass ?? .regular) == .regular && (self.horizontalSizeClass ?? .regular) == .compact {
                    self.portraitLayout
                } else {
                    self.landscapeLayout
                }
            }
            .alert(isPresented: self.navigationViewModel.dialogStateErrorBinding) {
                Alert(
                    title: Text(NunavStrings.errorGenericTitle),
                    message: Text(errorMessage(for: self.navigationViewModel.state.dialogState?.errorType)),
                    dismissButton: .destructive(
                        Text(NunavStrings.dialogActionClose),
                        action: self.navigationViewModel.dismissNavigation
                    )
                )
            }.alert(
                L10n.routeProgressViewDialogDestinationReachedTitle,
                isPresented: self.navigationViewModel.dialogStateDestinationReachedBinding,
                actions: {
                    Button(NunavStrings.dialogActionYes, role: .none) {
                        navigationViewModel.onUserInteracted(interaction: .onEndNavigationDialogCloseTapped)
                    }
                    Button(NunavStrings.dialogActionNo, role: .cancel) {
                        navigationViewModel.onUserInteracted(interaction: .dismissDialogButtonTapped)
                    }
                }, message: {
                    Text(L10n.routeProgressViewDialogEndNavigationSummary)
                }
            ).alert(
                L10n.routeProgressViewDialogEndNavigationTitle,
                isPresented: self.navigationViewModel.dialogStateEndNavigationBinding,
                actions: {
                    Button(NunavStrings.dialogActionYes, role: .none) {
                        navigationViewModel.onUserInteracted(interaction: .onEndNavigationDialogCloseTapped)
                    }
                    Button(NunavStrings.dialogActionNo, role: .cancel) {
                        navigationViewModel.onUserInteracted(interaction: .dismissDialogButtonTapped)
                    }
                }, message: {
                    Text(L10n.routeProgressViewDialogEndNavigationSummary)
                }
            )
            .confirmationDialog(
                L10n.contributionDialogTitle,
                isPresented: self.navigationViewModel.dialogStateContributionBinding,
                titleVisibility: .hidden
            ) {
                Button(L10n.contributionDialogMaptilerActionTitle, role: .none) {
                    self.navigationViewModel.onUserInteracted(interaction: .mapTilerContributionSelected)
                }
                Button(L10n.contributionDialogOpenstreetmapActionTitle, role: .none) {
                    self.navigationViewModel.onUserInteracted(interaction: .openStreetMapContributionSelected)
                }
                Button(L10n.contributionDialogNunavActionTitle, role: .none) {
                    self.navigationViewModel.onUserInteracted(interaction: .nunavMapContributionSelected)
                }
            }
            .onAppear(perform: {
                self.navigationViewModel.onAppear()
                self.routeProgressViewModel.onAppear()
                self.startMonitoringInternetConnection()
            }).onDisappear(perform: {
                self.navigationViewModel.onDisappear()
                self.routeProgressViewModel.onDisappear()
            })
        }
    }

    var portraitLayout: some View {
        GeometryReader { geometryProxy in
            VStack(spacing: .large) {
                if self.isNetworkMissing {
                    MapOverlayInfoView()
                        .transition(.move(edge: .top))
                } else {
                    Color.black.frame(height: .zero)
                }
                ManeuverCard(navigationSdk: navigationSdk)
                    .padding([.horizontal], Spacing.large.rawValue)
                MapOverlayButtonView(
                    state: self.navigationViewModel.state,
                    onVoiceInstructionButtonClicked: self.navigationViewModel.onVoiceInstructionButtonClicked,
                    onRouteOverviewButtonClicked: self.navigationViewModel.onRouteOverviewButtonClicked,
                    backToRouteButtonClicked: self.navigationViewModel.onBackToRouteButtonClicked,
                    onContributionButtonClicked: {
                        self.navigationViewModel.onUserInteracted(interaction: .onContributionButtonTapped)
                    }
                ).padding([.horizontal], Spacing.large.rawValue)
                RouteProgressView(
                    viewModel: self.routeProgressViewModel,
                    geometryProxy: geometryProxy,
                    landscapeMode: false,
                    onStopNavigationButtonTapped: {
                        self.navigationViewModel.onUserInteracted(interaction: .onEndNavigationButtonTapped)
                    }
                )
            }
        }
    }

    var landscapeLayout: some View {
        GeometryReader { geometryProxy in
            VStack(spacing: .large) {
                if self.isNetworkMissing {
                    MapOverlayInfoView()
                        .transition(.move(edge: .top))
                } else {
                    Color.black.frame(height: .zero)
                }
                HStack {
                    VStack {
                        ManeuverCard(navigationSdk: self.navigationSdk)
                        Spacer()
                        RouteProgressView(
                            viewModel: self.routeProgressViewModel,
                            geometryProxy: geometryProxy,
                            landscapeMode: true,
                            onStopNavigationButtonTapped: {
                                self.navigationViewModel.onUserInteracted(interaction: .onEndNavigationButtonTapped)
                            }
                        )
                    }.frame(minWidth: .zero, maxWidth: .infinity)
                        .layoutPriority(1)
                    VStack {
                        MapOverlayButtonView(
                            state: self.navigationViewModel.state,
                            onVoiceInstructionButtonClicked: self.navigationViewModel.onVoiceInstructionButtonClicked,
                            onRouteOverviewButtonClicked: self.navigationViewModel.onRouteOverviewButtonClicked,
                            backToRouteButtonClicked: self.navigationViewModel.onBackToRouteButtonClicked,
                            onContributionButtonClicked: {
                                self.navigationViewModel.onUserInteracted(interaction: .onContributionButtonTapped)
                            }
                        ).padding(.default)
                    }.frame(minWidth: .zero, maxWidth: .infinity)
                        .layoutPriority(1)
                }
            }
        }
    }

    // MARK: Functions

    private func errorMessage(for errorType: ErrorType?) -> String {
        switch errorType {
        case .routeNotFound:
            L10n.navigationErrorNoRouteFoundSummary
        case .unauthorized:
            L10n.navigationErrorUnauthorizedSummary
        case .none, .unknown:
            NunavStrings.errorUnknownTitle
        }
    }

    private func startMonitoringInternetConnection() {
        monitor.start(queue: DispatchQueue.global(qos: .background))
        monitor.pathUpdateHandler = { path in
            withAnimation {
                if path.status == .satisfied {
                    self.isNetworkMissing = false
                } else {
                    self.isNetworkMissing = true
                }
            }
        }
    }
}
