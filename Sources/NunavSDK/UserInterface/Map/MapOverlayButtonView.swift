import Foundation
import NunavDesignSystem
import NunavSDKMultiplatform
import SwiftUI

struct MapOverlayButtonView: View {
    // MARK: Static Properties

    private static var watermarkIconSize: CGFloat = 28

    // MARK: Properties

    private let state: NavigationUIState
    private let onVoiceInstructionButtonClicked: () -> Void

    @State private var contributionViewVisible: Bool = false

    // MARK: Lifecycle

    init(
        state: NavigationUIState,
        onVoiceInstructionButtonClicked: @escaping () -> Void
    ) {
        self.state = state
        self.onVoiceInstructionButtonClicked = onVoiceInstructionButtonClicked
    }

    // MARK: Content

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
                Image(uiImage: Asset.Map.watermark.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: MapOverlayButtonView.watermarkIconSize)
                    .onTapGesture {
                        self.contributionViewVisible = true
                    }
                Spacer()
            }.confirmationDialog(L10n.contributionDialogTitle, isPresented: self.$contributionViewVisible, titleVisibility: .hidden) {
                Button(L10n.contributionDialogMaptilerActionTitle, role: .none) {
                    self.mapTilerMapContributionDidPress()
                }
                Button(L10n.contributionDialogOpenstreetmapActionTitle, role: .none) {
                    self.openStreetMapContributionDidPress()
                }
                Button(L10n.contributionDialogNunavActionTitle, role: .none) {
                    self.nunavMapContributionDidPress()
                }
            }
        }
    }

    // MARK: Functions

    func nunavMapContributionDidPress() {
        UIApplication.shared.open(
            URL(string: "https://github.com/Graphmasters/nunav-sdk-example")!, options: [:], completionHandler: nil
        )
    }

    func openStreetMapContributionDidPress() {
        UIApplication.shared.open(
            URL(string: "https://www.openstreetmap.org/copyright")!, options: [:], completionHandler: nil
        )
    }

    func mapTilerMapContributionDidPress() {
        UIApplication.shared.open(
            URL(string: "https://www.maptiler.com/copyright/")!, options: [:], completionHandler: nil
        )
    }
}
