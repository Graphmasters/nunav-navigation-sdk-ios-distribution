import Combine
import Foundation
import MultiplatformNavigation
import NunavDesignSystem
import SwiftUI

struct ManeuverCard: View {
    // MARK: SwiftUI Properties

    @StateObject private var viewModel: ViewModel

    @State private var state: ManeuverUIState?

    // MARK: Lifecycle

    init(navigationSdk: NavigationSdk) {
        self._viewModel = StateObject(
            wrappedValue: .init(navigationSdk: navigationSdk)
        )
    }

    // MARK: Content Properties

    var body: some View {
        Self.ContentView(
            state: state ?? .Loading(detached: false)
        )
        .onAppear(perform: viewModel.onAppear)
        .onDisappear(perform: viewModel.onDisappear)
        .onReceive(viewModel.$state) { state in
            withAnimation {
                self.state = state
            }
        }
    }
}
