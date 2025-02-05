import Foundation
import MultiplatformNavigation
import NunavDesignSystem
import SwiftUI

struct MapOverlayInfoView: View {
    var body: some View {
        ZStack {
            Color.DesignSystem.errorContainer
                .edgesIgnoringSafeArea([.top, .leading, .trailing])
            HStack(spacing: .default) {
                Icon(.icNoInternet, style: .custom(Size.Icon.default, iconColor: .DesignSystem.onErrorContainer))
                Text(L10n.maneuverProgressViewInternetMissingError)
                    .foregroundColor(Color.DesignSystem.onErrorContainer)
                    .font(.DesignSystem.Body.small)
            }.padding(.default).frame(
                maxWidth: .infinity,
                minHeight: 0
            ).layoutPriority(1)
        }
    }
}
