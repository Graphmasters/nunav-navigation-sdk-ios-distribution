import Foundation
import NunavDesignSystem
import NunavSDKMultiplatform
import SwiftUI

struct MapOverlayButtonView: View {
    private static var watermarkIconSize: CGFloat = 28

    private let state: NavigationUIState
    private let onVoiceInstructionButtonClicked: () -> Void

    @State private var contributionViewVisible: Bool = false

    init(
        state: NavigationUIState,
        onVoiceInstructionButtonClicked: @escaping () -> Void
    ) {
        self.state = state
        self.onVoiceInstructionButtonClicked = onVoiceInstructionButtonClicked
    }

    var body: some View {
        VStack {
            HStack {
                Spacer()
                MapOverlayButton(
                    image: state.voiceInstructionsEnabled == true
                        ? Asset.Buttons.soundOn.image
                        : Asset.Buttons.soundOff.image,
                    action: onVoiceInstructionButtonClicked
                )
            }
            Spacer()
            HStack {
                Image(uiImage: Asset.Map.watermark.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: MapOverlayButtonView.watermarkIconSize)
                    .onTapGesture {
                        contributionViewVisible = true
                    }
                Spacer()
            }.confirmationDialog(L10n.contributionDialogTitle, isPresented: $contributionViewVisible, titleVisibility: .hidden) {
                Button(L10n.contributionDialogMaptilerActionTitle, role: .none) {
                    mapTilerMapContributionDidPress()
                }
                Button(L10n.contributionDialogOpenstreetmapActionTitle, role: .none) {
                    openStreetMapContributionDidPress()
                }
                Button(L10n.contributionDialogNunavActionTitle, role: .none) {
                    nunavMapContributionDidPress()
                }
            }
        }
    }

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
