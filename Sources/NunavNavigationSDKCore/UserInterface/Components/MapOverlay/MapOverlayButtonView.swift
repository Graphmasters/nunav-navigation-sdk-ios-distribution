import Foundation
import MultiplatformNavigation
import NunavDesignSystem
import SwiftUI

struct MapOverlayButtonView: View {
    // MARK: Static Properties

    private static var watermarkIconSize: CGFloat = 28

    // MARK: Properties

    private let state: NavigationScreen.UIState
    private let onVoiceInstructionButtonClicked: () -> Void
    private let onRouteOverviewButtonClicked: () -> Void
    private let backToRouteButtonClicked: () -> Void
    private let onContributionButtonClicked: () -> Void

    // MARK: Lifecycle

    init(
        state: NavigationScreen.UIState,
        onVoiceInstructionButtonClicked: @escaping () -> Void,
        onRouteOverviewButtonClicked: @escaping () -> Void,
        backToRouteButtonClicked: @escaping () -> Void,
        onContributionButtonClicked: @escaping () -> Void
    ) {
        self.state = state
        self.onVoiceInstructionButtonClicked = onVoiceInstructionButtonClicked
        self.onRouteOverviewButtonClicked = onRouteOverviewButtonClicked
        self.backToRouteButtonClicked = backToRouteButtonClicked
        self.onContributionButtonClicked = onContributionButtonClicked
    }

    // MARK: Content Properties

    var body: some View {
        VStack {
            HStack {
                Spacer()
                MapOverlayButton(
                    icon: self.state.voiceInstructionsEnabled == true
                        ? .icSoundOn
                        : .icSoundOff,
                    action: self.onVoiceInstructionButtonClicked
                )
            }
            Spacer()
            HStack {
                switch state.interactionMode {
                case .following:
                    Image(uiImage: UIImage.Map.watermark)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: MapOverlayButtonView.watermarkIconSize)
                        .onTapGesture(perform: onContributionButtonClicked)
                case .overview:
                    MapOverlayAnimatedBackToRouteButton(
                        action: self.backToRouteButtonClicked,
                        duration: 10,
                        animate: true
                    )
                case .interacting:
                    MapOverlayAnimatedBackToRouteButton(
                        action: self.backToRouteButtonClicked,
                        duration: 10,
                        animate: false
                    )
                case .loading:
                    Spacer()
                }
                Spacer()
                MapOverlayButton(
                    icon: .icRouteOverview,
                    action: self.onRouteOverviewButtonClicked
                )
            }
        }
    }
}
