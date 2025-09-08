import Foundation
import MultiplatformNavigation
import NunavDesignSystem
import SwiftUI

struct MapOverlayButtonView: View {
    // MARK: Nested Types

    private enum Constants {
        static let watermarkIconSize: CGFloat = 28
        static let overviewButtonAnimationDuration: TimeInterval = 10
    }

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
                        .frame(height: Constants.watermarkIconSize)
                        .onTapGesture(perform: onContributionButtonClicked)
                case .overview:
                    MapOverlayAnimatedBackToRouteButton(
                        action: self.backToRouteButtonClicked,
                        duration: Constants.overviewButtonAnimationDuration,
                        animate: true
                    )
                case .interacting:
                    MapOverlayAnimatedBackToRouteButton(
                        action: self.backToRouteButtonClicked,
                        duration: Constants.overviewButtonAnimationDuration,
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
