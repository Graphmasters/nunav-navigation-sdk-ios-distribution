import Combine
import Foundation
import MultiplatformNavigation
import NunavDesignSystem
import SwiftUI

struct ManeuverCard: View {
    // MARK: SwiftUI Properties

    @StateObject private var viewModel: ManeuverCard.ViewModel

    // MARK: Properties

    @SwiftUI.State private var state: ManeuverUIState?

    // MARK: Lifecycle

    init(navigationSdk: NavigationSdk) {
        self._viewModel = StateObject(
            wrappedValue: .init(
                navigationSdk: navigationSdk,
                detachStateProvider: OffRouteDetachStateProvider(navigationSdk: navigationSdk)
            )
        )
    }

    // MARK: Content Properties

    var body: some View {
        ManeuverCard.ContentView(
            state: state ?? .Loading(detached: false)
        ).onAppear(perform: viewModel.onAppear)
            .onDisappear(perform: viewModel.onDisappear)
            .onReceive(viewModel.$state) { state in
                withAnimation {
                    self.state = state
                }
            }
    }
}
