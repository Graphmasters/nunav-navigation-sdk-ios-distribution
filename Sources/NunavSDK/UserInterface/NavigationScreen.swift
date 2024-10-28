import Foundation
import Network
import NunavDesignSystem
import NunavSDKMultiplatform
import SwiftUI

struct NavigationScreen: View {
    // MARK: Static Properties

    static let internetViewHeight: CGFloat = 74

    // MARK: Properties

    let monitor = NWPathMonitor()

    @State var state: NavigationUIState?
    @State var errorDialogShown: Bool = false

    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    private let navigationViewModel: NavigationViewModel
    private let routeProgressViewModel: RouteProgressViewModel
    private let maneuverViewModel: ManeuverViewModel

    @State private var isNetworkMissing = false

    // MARK: Lifecycle

    init(
        navigationViewModel: NavigationViewModel,
        routeProgressViewModel: RouteProgressViewModel,
        maneuverViewModel: ManeuverViewModel
    ) {
        self.navigationViewModel = navigationViewModel
        self.routeProgressViewModel = routeProgressViewModel
        self.maneuverViewModel = maneuverViewModel
    }

    // MARK: Content

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
                if (self.verticalSizeClass ?? .regular) == .regular && (self.horizontalSizeClass ?? .regular) == .compact {
                    self.portraitLayout
                } else {
                    self.landscapeLayout
                }
            }
            .alert(
                L10n.routeProgressViewDialogEndNavigationTitle,
                isPresented: self.$errorDialogShown,
                actions: {
                    Button(L10n.navigationScreenDialogActionClose, role: .none) {
                        DispatchQueue.global(qos: .background).async {
                            NunavSDK.navigationSdk.stopNavigation()
                        }
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
                self.startMonitoringInternetConnection()
                self.state = self.navigationViewModel.state.value
                Task {
                    for await state in self.navigationViewModel.state {
                        self.state = state
                        self.errorDialogShown = state?.navigationError?.critical == true
                        NavigationUI.voiceInstructionComponent.enabled = state?.voiceInstructionsEnabled ?? false
                    }
                }
            }).onDisappear(perform: {
                self.navigationViewModel.onCleared()
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
                ManeuverProgressView(viewModel: self.maneuverViewModel)
                    .padding([.horizontal], Spacing.large.rawValue)
                if let state = state {
                    MapOverlayButtonView(
                        state: state,
                        onVoiceInstructionButtonClicked: self.navigationViewModel.onVoiceInstructionButtonClicked
                    ).padding([.horizontal], Spacing.large.rawValue)
                } else {
                    Spacer()
                }
                RouteProgressView(viewModel: self.routeProgressViewModel, geometryProxy: geometryProxy, landscapeMode: false)
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
                        ManeuverProgressView(viewModel: self.maneuverViewModel)
                        Spacer()
                        RouteProgressView(viewModel: self.routeProgressViewModel, geometryProxy: geometryProxy, landscapeMode: true)
                    }.frame(minWidth: .zero, maxWidth: .infinity)
                        .layoutPriority(1)
                    VStack {
                        if let state = state {
                            MapOverlayButtonView(
                                state: state,
                                onVoiceInstructionButtonClicked: self.navigationViewModel.onVoiceInstructionButtonClicked
                            ).padding(.default)
                        } else {
                            Spacer()
                        }
                    }.frame(minWidth: .zero, maxWidth: .infinity)
                        .layoutPriority(1)
                }
            }
        }
    }

    // MARK: Functions

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
