import Combine
import Foundation
import MultiplatformNavigation

extension ManeuverCard {
    class ViewModel: ObservableObject {
        // MARK: Properties

        @Published private(set) var state: ManeuverUIState = .Loading(detached: false)

        private let navigationSdk: NavigationSdk
        private let detachStateProvider: RouteDetachStateProvider
        private let maneuverUIStateConverter: ManeuverUIStateConverter

        // MARK: Lifecycle

        init(
            navigationSdk: NavigationSdk,
            detachStateProvider: RouteDetachStateProvider,
            maneuverUIStateConverter: ManeuverUIStateConverter = ManeuverUIStateConverter()
        ) {
            self.navigationSdk = navigationSdk
            self.detachStateProvider = detachStateProvider
            self.maneuverUIStateConverter = maneuverUIStateConverter
        }

        // MARK: Functions

        func onAppear() {
            navigationSdk.addOnNavigationStateUpdatedListener(onNavigationStateUpdatedListener: self)
        }

        func onDisappear() {
            navigationSdk.removeOnNavigationStateUpdatedListener(onNavigationStateUpdatedListener: self)
        }

        private func update() {
            state = maneuverUIStateConverter.convert(
                navigationState: navigationSdk.navigationState,
                lastManeuverUIState: state,
                detached: detachStateProvider.detached
            )
        }
    }
}

extension ManeuverCard.ViewModel: OnNavigationStateUpdatedListener {
    func onNavigationStateUpdated(navigationState _: NavigationState?) {
        update()
    }
}
