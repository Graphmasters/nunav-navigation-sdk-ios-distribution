import Foundation
import NunavDesignSystem
import NunavSDKMultiplatform
import SwiftUI

struct MapOverlayInfoView: View {
    var body: some View {
        ZStack {
            Color.DesignSystem.errorContainer
                .edgesIgnoringSafeArea([.top, .leading, .trailing])
            HStack(spacing: Size.Padding.default) {
                Image(
                    uiImage: Asset.noInternet.image.withRenderingMode(.alwaysTemplate)
                        .withRenderingMode(.alwaysTemplate)
                ).foregroundColor(Color.DesignSystem.onErrorContainer)
                Text(L10n.maneuverProgressViewInternetMissingError)
                    .foregroundColor(Color.DesignSystem.onErrorContainer)
                    .font(.DesignSystem.Body.small)
            }.padding(Size.Padding.default).frame(
                maxWidth: .infinity,
                minHeight: 0
            ).layoutPriority(1)
        }
    }
}
