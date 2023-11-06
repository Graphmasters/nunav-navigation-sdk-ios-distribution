import Foundation
import Network
import NunavDesignSystem
import NunavSDKMultiplatform
import SwiftUI

struct NavigationScreen: View {
    private let navigationViewModel: NavigationViewModel
    private let routeProgressViewModel: RouteProgressViewModel
    private let maneuverViewModel: ManeuverViewModel

    static let internetViewHeight: CGFloat = 74

    @State private var isNetworkMissing = false
    let monitor = NWPathMonitor()

    init(
        navigationViewModel: NavigationViewModel,
        routeProgressViewModel: RouteProgressViewModel,
        maneuverViewModel: ManeuverViewModel
    ) {
        self.navigationViewModel = navigationViewModel
        self.routeProgressViewModel = routeProgressViewModel
        self.maneuverViewModel = maneuverViewModel
    }

    @State var state: NavigationUIState?
    @State var errorDialogShown: Bool = false

    @Environment(\.scenePhase) var scenePhase
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    var body: some View {
        ZStack {
            MapView()
                .edgesIgnoringSafeArea(.all)
            VStack {
                Color.clear
                    .edgesIgnoringSafeArea([.top, .leading, .trailing])
                    .background(.ultraThinMaterial)
                Spacer()
                    .layoutPriority(1)
            }
            VStack {
                if (verticalSizeClass ?? .regular) == .regular && (horizontalSizeClass ?? .regular) == .compact {
                    portraitLayout
                } else {
                    landscapeLayout
                }
            }
            .alert(
                L10n.routeProgressViewDialogEndNavigationTitle,
                isPresented: $errorDialogShown,
                actions: {
                    Button(L10n.navigationScreenDialogActionClose, role: .none) {
                        NunavSDK.navigationSdk.stopNavigation()
                    }
                }, message: {
                    if let error = state?.navigationError {
                        switch error.type {
                        case .noRouteFound:
                            Text(L10n.navigationErrorNoRouteFoundSummary)
                        case .unauthorized:
                            Text(L10n.navigationErrorUnauthorizedSummary)
                        case .unknown:
                            if let message = state?.navigationError?.exception.message {
                                Text(message)
                            }
                        }
                    }

                }
            )
            .onAppear(perform: {
                startMonitoringInternetConnection()
                state = navigationViewModel.state.value
                Task {
                    for await state in navigationViewModel.state {
                        self.state = state
                        self.errorDialogShown = state?.navigationError?.critical == true
                        NavigationUI.voiceInstructionComponent.enabled = state?.voiceInstructionsEnabled ?? false
                    }
                }
            }).onDisappear(perform: {
                navigationViewModel.onCleared()
            })
        }
    }

    var portraitLayout: some View {
        GeometryReader { geometryProxy in
            VStack(spacing: Size.Padding.large) {
                if isNetworkMissing {
                    MapOverlayInfoView()
                        .transition(.move(edge: .top))
                } else {
                    Color.black.frame(height: .zero)
                }
                ManeuverProgressView(viewModel: maneuverViewModel)
                    .padding([.horizontal], Size.Padding.large)
                if let state = state {
                    MapOverlayButtonView(
                        state: state,
                        onVoiceInstructionButtonClicked: navigationViewModel.onVoiceInstructionButtonClicked
                    ).padding([.horizontal], Size.Padding.large)
                } else {
                    Spacer()
                }
                RouteProgressView(viewModel: routeProgressViewModel, geometryProxy: geometryProxy, landscapeMode: false)
            }
        }
    }

    var landscapeLayout: some View {
        GeometryReader { geometryProxy in
            VStack(spacing: Size.Padding.large) {
                if isNetworkMissing {
                    MapOverlayInfoView()
                        .transition(.move(edge: .top))
                } else {
                    Color.black.frame(height: .zero)
                }
                HStack {
                    VStack {
                        ManeuverProgressView(viewModel: maneuverViewModel)
                        Spacer()
                        RouteProgressView(viewModel: routeProgressViewModel, geometryProxy: geometryProxy, landscapeMode: true)
                    }.frame(minWidth: .zero, maxWidth: .infinity)
                        .layoutPriority(1)
                    VStack {
                        if let state = state {
                            MapOverlayButtonView(
                                state: state,
                                onVoiceInstructionButtonClicked: navigationViewModel.onVoiceInstructionButtonClicked
                            ).padding(Size.Padding.default)
                        } else {
                            Spacer()
                        }
                    }.frame(minWidth: .zero, maxWidth: .infinity)
                        .layoutPriority(1)
                }
            }
        }
    }

    private func startMonitoringInternetConnection() {
        monitor.start(queue: DispatchQueue.global(qos: .background))
        monitor.pathUpdateHandler = { path in
            withAnimation {
                if path.status == .satisfied {
                    isNetworkMissing = false
                } else {
                    isNetworkMissing = true
                }
            }
        }
    }
}
