import Foundation
import MultiplatformNavigation

class RouteProgressViewModel: ObservableObject {
    // MARK: Properties

    @Published var state: RouteProgressUIState = .Loading()

    private let navigationSdk: NavigationSdk
    private let routeProgressUIStateConverter: RouteProgressUIStateConverter

    // MARK: Lifecycle

    init(
        navigationSdk: NavigationSdk,
        routeProgressUIStateConverter: RouteProgressUIStateConverter = RouteProgressUIStateConverter()
    ) {
        self.navigationSdk = navigationSdk
        self.routeProgressUIStateConverter = routeProgressUIStateConverter
    }

    // MARK: Functions

    @MainActor func onAppear() {
        navigationSdk.addOnNavigationStateUpdatedListener(onNavigationStateUpdatedListener: self)
    }

    @MainActor func onDisappear() {
        navigationSdk.removeOnNavigationStateUpdatedListener(onNavigationStateUpdatedListener: self)
    }

    private func update() {
        state = routeProgressUIStateConverter.convert(
            navigationState: navigationSdk.navigationState,
            detached: navigationSdk.navigationState?.displayInformation.shouldShowUserOffRoute ?? false
        )
    }
}

extension RouteProgressViewModel: OnNavigationStateUpdatedListener {
    func onNavigationStateUpdated(navigationState _: NavigationState?) {
        update()
    }
}
