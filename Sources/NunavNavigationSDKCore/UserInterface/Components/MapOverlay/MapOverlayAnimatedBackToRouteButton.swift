import NunavDesignSystem
import SwiftUI

struct MapOverlayAnimatedBackToRouteButton: View {
    // MARK: SwiftUI Properties

    @State private var timer = Timer.publish(every: 0.01, on: .current, in: .common).autoconnect()
    @State private var timerCount: CGFloat = 0
    @State private var progress: CGFloat = 0

    // MARK: Properties

    private let action: @MainActor () -> Void
    private let duration: CGFloat?
    private let animate: Bool

    // MARK: Lifecycle

    init(
        action: @escaping () -> Void,
        duration: CGFloat?,
        animate: Bool
    ) {
        self.action = action
        self.duration = duration
        self.animate = animate
    }

    // MARK: Content Properties

    var body: some View {
        MapOverlay {
            Button {
                self.action()
            } label: {
                HStack(spacing: .small) {
                    Icon(.icLocate, style: .onSurfacePrimary)
                    Text(L10n.mapOverlayBackToRouteButtonTitle)
                        .font(.DesignSystem.Button.default)
                        .lineLimit(1)
                }.padding(.default)
                    .foregroundColor(.DesignSystem.onSurfacePrimary)
                    .background(Color.DesignSystem.surfaceCard)
                    .overlay {
                        GeometryReader { geometry in
                            HStack(spacing: .small) {
                                Icon(.icLocate, style: .onPrimary)
                                Text(L10n.mapOverlayBackToRouteButtonTitle)
                                    .font(.DesignSystem.Button.default)
                                    .lineLimit(1)
                            }.padding(.default)
                                .foregroundColor(.DesignSystem.onPrimary)
                                .background(Color.DesignSystem.primary)
                                .clipShape(Rectangle().size(width: geometry.size.width * self.progress, height: geometry.size.height))
                        }
                    }
            }
            .cornerRadius(.default)
            .onReceive(self.timer, perform: { _ in
                self.progressStep()
            })
        }.frame(height: Size.Button.height)
    }

    // MARK: Functions

    private func progressStep() {
        guard animate else {
            return
        }
        if progress != 1, let duration = duration {
            timerCount += 0.01
            progress = easeInOutCubic(timerCount / duration)
        } else {
            progress = 0
            timerCount = 0
            cancelTimer()
            action()
        }
    }

    private func easeInOutCubic(_ x: Double) -> Double {
        return x < 0.5 ? 4 * x * x * x : 1 - pow(-2 * x + 2, 3) / 2
    }

    private func cancelTimer() {
        timer.upstream.connect().cancel()
    }
}

#Preview {
    MapOverlayAnimatedBackToRouteButton(
        action: {},
        duration: 5,
        animate: true
    )
}
