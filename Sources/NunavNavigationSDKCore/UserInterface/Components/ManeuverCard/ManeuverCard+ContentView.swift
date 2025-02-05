import MultiplatformNavigation
import NunavDesignSystem
import SwiftUI

extension ManeuverCard {
    struct ContentView: View {
        // MARK: Static Properties

        static let topViewImageHeight: CGFloat = 48
        static let bottomViewHeight: CGFloat = 36

        // MARK: Properties

        private let state: ManeuverUIState

        // MARK: Lifecycle

        init(state: ManeuverUIState) {
            self.state = state
        }

        // MARK: Content Properties

        var body: some View {
            HStack {
                HStack {
                    switch onEnum(of: state) {
                    case let .followingRoute(followingRoute):
                        ZStack(alignment: .top) {
                            VStack(spacing: .zero) {
                                TopContentHolderView()
                                Color.DesignSystem.surfaceCardOutline.frame(height: 1)
                                if let secondaryInfo = followingRoute.secondaryManeuverInfo {
                                    BottomView(secondaryInfo: secondaryInfo)
                                        .frame(minWidth: .zero, maxWidth: .infinity)
                                        .padding(.tiny)
                                        .background(Color.DesignSystem.surfacePrimary)
                                        .transition(.move(edge: .top))
                                }
                            }.transition(.move(edge: .top).combined(with: .opacity))
                            TopContentHolderView(
                                view: UpcomingManeuverView(
                                    state: followingRoute
                                )
                            )
                        }
                    case let .loading(loading):
                        TopContentHolderView(
                            view: TopLoadingView(
                                title: loading.detached
                                    ? L10n.maneuverProgressViewLoadingDetachedTitle
                                    : L10n.maneuverProgressViewLoadingInitialRouteTitle
                            )
                        )
                    }
                }.cornerRadius(CornerRadius.default)
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.default.rawValue)
                            .stroke(Color.DesignSystem.onMapSurfaceOutline, lineWidth: Size.OnMapSurface.outlineWidth)
                    )
            }
        }
    }

    struct BottomView: View {
        // MARK: Properties

        let secondaryInfo: ManeuverUIState.SecondaryManeuverInfo

        // MARK: Content Properties

        var body: some View {
            Group {
                switch onEnum(of: self.secondaryInfo) {
                case let .laneInfo(laneInfo):
                    LaneAssistView(laneIcons: laneInfo.laneIcons)
                case let .followingManeuver(followingManeuver):
                    FollowingManeuverView(
                        turnIcon: followingManeuver.maneuverIcon,
                        text: L10n.maneuverProgressViewFollowingManeuverText(
                            FormattedLength.localizedString(for: followingManeuver.formattedLength)
                        )
                    )
                }
            }.transaction { transaction in
                transaction.animation = nil
            }
        }
    }

    struct FollowingManeuverView: View {
        // MARK: Properties

        let turnIcon: ManeuverIconProvider.ManeuverIcon
        let text: String

        // MARK: Content Properties

        var body: some View {
            HStack(spacing: .default) {
                Text(self.text)
                    .font(.DesignSystem.Body.large)
                    .foregroundColor(.DesignSystem.onSurfacePrimary)
                Image(uiImage: ManeuverIconProvider.ManeuverIcon.image(for: self.turnIcon)
                    .withRenderingMode(.alwaysTemplate))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.DesignSystem.onSurfacePrimary)
            }.padding(.tiny)
                .frame(height: ManeuverCard.ContentView.bottomViewHeight)
        }
    }

    struct LaneAssistView: View {
        // MARK: Properties

        let laneIcons: [LaneIcon]

        // MARK: Content Properties

        var body: some View {
            HStack(spacing: .zero) {
                ForEach(0 ..< self.laneIcons.count, id: \.self) { index in
                    Image(uiImage: LaneIcon.image(for: self.laneIcons[index]).withRenderingMode(.alwaysTemplate))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.DesignSystem.onSurfacePrimary)
                }
            }.padding(.tiny)
                .frame(height: ManeuverCard.ContentView.bottomViewHeight)
        }
    }

    struct TopLoadingView: View {
        // MARK: Properties

        private let title: String

        // MARK: Lifecycle

        init(title: String) {
            self.title = title
        }

        // MARK: Content Properties

        var body: some View {
            HStack(alignment: .center, spacing: .default) {
                ZStack(alignment: .center) {
                    Color.DesignSystem.surfaceCard.frame(
                        width: ManeuverCard.ContentView.topViewImageHeight,
                        height: ManeuverCard.ContentView.topViewImageHeight
                    ).opacity(.zero)
                    ProgressView()
                }
                Text(self.title)
                    .font(.DesignSystem.Headline.default)
                    .foregroundColor(.DesignSystem.onSurfacePrimary)
                Spacer()
            }.frame(minWidth: .zero, maxWidth: .infinity)
        }
    }

    struct TopContentHolderView: View {
        // MARK: Properties

        private let innerView: (any View)?

        // MARK: Lifecycle

        init(view: (any View)? = nil) {
            self.innerView = view
        }

        // MARK: Content Properties

        var body: some View {
            ZStack {
                TopPlaceholderView()
                self.innerView.map { AnyView($0) }
            }.padding(.large)
                .background(Color.DesignSystem.surfaceCard)
        }
    }

    struct TopPlaceholderView: View {
        var body: some View {
            TopContentView(title: "8")
                .opacity(.zero)
        }
    }

    struct UpcomingManeuverView: View {
        // MARK: Properties

        let state: ManeuverUIState.FollowingRoute

        // MARK: Content Properties

        var body: some View {
            TopContentView(
                image: ManeuverIconProvider.ManeuverIcon.image(for: state.primaryManeuverInfo.maneuverIcon),
                title: state.primaryManeuverInfo.formattedLength.value,
                titleAddition: FormattedLength.localizedString(for: state.primaryManeuverInfo.formattedLength.unit),
                cue: state.primaryManeuverInfo.maneuverCue
            )
        }
    }

    struct TopContentView: View {
        // MARK: Nested Types

        private struct CueView: View {
            // MARK: Properties

            private let roadShieldTextPadding: CGFloat = 2
            private let cue: Maneuver.Cue

            // MARK: Lifecycle

            public init(cue: Maneuver.Cue) {
                self.cue = cue
            }

            // MARK: Content Properties

            var body: some View {
                HStack(spacing: .small) {
                    if let label = cue.label {
                        ZStack {
                            Image(uiImage: self.getImage(for: label))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                            BodyText(label.shield, style: .small(textColor: Color(uiColor: self.getFontColor(for: label))))
                                .padding(self.roadShieldTextPadding)
                        }.fixedSize()
                        if let destinationName = label.destinationName {
                            Text(destinationName)
                                .lineLimit(1)
                                .font(.DesignSystem.Body.large)
                                .foregroundColor(.DesignSystem.onSurfacePrimary)
                        }
                    } else {
                        Text(self.cue.fullLabel)
                            .lineLimit(1)
                            .font(.DesignSystem.Body.large)
                            .foregroundColor(.DesignSystem.onSurfacePrimary)
                    }
                }
            }

            // MARK: Functions

            private func getImage(for cueLabel: Maneuver.CueLabel) -> UIImage {
                if cueLabel is Maneuver.CueLabelGermanAutobahn {
                    return UIImage.ManeuverCard.icShieldFederalHighwayDe
                }
                if cueLabel is Maneuver.CueLabelGermanBundesstrasse {
                    return UIImage.ManeuverCard.icShieldMotorwayDe
                }
                return UIImage.ManeuverCard.icShieldFederalHighwayGeneric
            }

            private func getFontColor(for cueLabel: Maneuver.CueLabel) -> UIColor {
                if cueLabel is Maneuver.CueLabelGermanAutobahn {
                    return UIColor.roadShieldAutobahnDEFont
                }
                if cueLabel is Maneuver.CueLabelGermanBundesstrasse {
                    return UIColor.roadShieldBundesstraßeDEFont
                }
                return UIColor.roadShieldGenericFont
            }
        }

        // MARK: Properties

        private let loading: Bool
        private let image: UIImage?
        private let title: String
        private let titleAddition: String?
        private let cue: Maneuver.Cue?

        // MARK: Lifecycle

        init(loading: Bool = false, image: UIImage? = nil, title: String, titleAddition: String? = nil, cue: Maneuver.Cue? = nil) {
            self.loading = loading
            self.image = image
            self.title = title
            self.titleAddition = titleAddition
            self.cue = cue
        }

        // MARK: Content Properties

        var body: some View {
            HStack(alignment: .center, spacing: .default) {
                ZStack {
                    Color.DesignSystem.surfaceCard.frame(
                        width: ManeuverCard.ContentView.topViewImageHeight,
                        height: ManeuverCard.ContentView.topViewImageHeight
                    ).opacity(.zero)
                    self.image.map {
                        Image(
                            uiImage: $0.withRenderingMode(.alwaysTemplate)
                        ).resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.DesignSystem.onSurfacePrimary)
                            .frame(height: ManeuverCard.ContentView.topViewImageHeight)
                    }
                    if self.loading {
                        ProgressView()
                            .frame(height: ManeuverCard.ContentView.topViewImageHeight)
                    }
                }
                VStack(alignment: .leading, spacing: .tiny) {
                    HStack(alignment: .firstTextBaseline, spacing: .tiny) {
                        Text(self.title)
                            .font(.DesignSystem.Headline.large)
                            .foregroundColor(.DesignSystem.onSurfacePrimary)
                        self.titleAddition.map {
                            Text($0)
                                .font(.DesignSystem.Headline.small)
                                .foregroundColor(.DesignSystem.onSurfaceSecondary)
                        }
                    }
                    if let cue = cue {
                        CueView(cue: cue)
                    }
                }
                Spacer()
            }.transaction { transaction in
                transaction.animation = nil
            }.frame(
                minWidth: .zero,
                maxWidth: .infinity,
                maxHeight: ManeuverCard.ContentView.topViewImageHeight
            )
        }
    }
}
