import Combine
import Foundation
import NunavDesignSystem
import NunavSDKMultiplatform
import SwiftUI

struct ManeuverProgressView: View {
    static let topViewImageHeight: CGFloat = 48
    static let bottomViewHeight: CGFloat = 36

    private var viewModel: ManeuverViewModel

    @State private var state: ManeuverUIState

    init(viewModel: ManeuverViewModel) {
        self.viewModel = viewModel
        state = viewModel.state.value
    }

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
                                    .padding(Size.Padding.tiny)
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
            }.cornerRadius(Size.SurfaceCard.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: Size.OnMapSurface.cornerRadius)
                        .stroke(Color.DesignSystem.onMapSurfaceOutline, lineWidth: Size.OnMapSurface.outlineWidth)
                )
        }.onAppear(perform: {
            self.state = state
            Task {
                for await state in viewModel.state {
                    withAnimation {
                        self.state = state
                    }
                }
            }
        })
    }
}

struct BottomView: View {
    let secondaryInfo: ManeuverUIStateSecondaryManeuverInfo
    private let defaultLaneIconProvider: DefaultLaneImageProvider = .init()
    private let defaultManeuverIconProvider: DefaultManeuverImageProvider = .init()

    var body: some View {
        Group {
            switch onEnum(of: secondaryInfo) {
            case let .laneInfo(laneInfo):
                let icons = laneInfo.laneIcons.map { icon in
                    defaultLaneIconProvider.getImage(icon: icon)
                }
                LaneAssistView(laneIcons: icons)
            case let .followingManeuver(followingManeuver):
                FollowingManeuverView(
                    turnIcon: defaultManeuverIconProvider.getImage(icon: followingManeuver.maneuverIcon),
                    text: L10n.maneuverProgressViewFollowingManeuverText(followingManeuver.formattedDistance.formattedString())
                )
            }
        }.transaction { transaction in
            transaction.animation = nil
        }
    }
}

struct FollowingManeuverView: View {
    let turnIcon: UIImage
    let text: String

    var body: some View {
        HStack(spacing: Size.Padding.default) {
            Text(text)
                .font(.DesignSystem.Body.large)
                .foregroundColor(.DesignSystem.onSurfacePrimary)
            Image(uiImage: turnIcon.withRenderingMode(.alwaysTemplate))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.DesignSystem.onSurfacePrimary)
        }.padding(Size.Padding.tiny)
            .frame(height: ManeuverProgressView.bottomViewHeight)
    }
}

struct LaneAssistView: View {
    let laneIcons: [UIImage]

    var body: some View {
        HStack(spacing: .zero) {
            ForEach(0 ..< laneIcons.count, id: \.self) { index in
                Image(uiImage: laneIcons[index].withRenderingMode(.alwaysTemplate))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.DesignSystem.onSurfacePrimary)
            }
        }.padding(Size.Padding.tiny)
            .frame(height: ManeuverProgressView.bottomViewHeight)
    }
}

struct TopLoadingView: View {
    private let title: String

    init(title: String) {
        self.title = title
    }

    var body: some View {
        HStack(alignment: .center, spacing: Size.Padding.default) {
            ZStack(alignment: .center) {
                Color.DesignSystem.surfaceCard.frame(
                    width: ManeuverProgressView.topViewImageHeight,
                    height: ManeuverProgressView.topViewImageHeight
                ).opacity(.zero)
                ProgressView()
            }
            Text(title)
                .font(.DesignSystem.Headline.default)
                .foregroundColor(.DesignSystem.onSurfacePrimary)
            Spacer()
        }.frame(minWidth: .zero, maxWidth: .infinity)
    }
}

struct TopContentHolderView: View {
    private let innerView: (any View)?

    init(view: (any View)? = nil) {
        innerView = view
    }

    var body: some View {
        ZStack {
            TopPlaceholderView()
            innerView.map { AnyView($0) }
        }.padding(Size.Padding.large)
            .background(Color.DesignSystem.surfaceCard)
    }
}

struct TopPlaceholderView: View {
    var body: some View {
        TopContentView(title: "8", subtitle: "8")
            .opacity(.zero)
    }
}

struct UpcomingManeuverView: View {
    let state: ManeuverUIStateFollowingRoute
    private let defaultManeuverIconProvider: DefaultManeuverImageProvider = .init()

    var body: some View {
        TopContentView(
            image: defaultManeuverIconProvider.getImage(icon: state.primaryManeuverInfo.maneuverIcon),
            title: state.primaryManeuverInfo.formattedDistance.value,
            titleAddition: state.primaryManeuverInfo.formattedDistance.unit,
            subtitle: state.primaryManeuverInfo.destinationName
        )
    }
}

struct TopContentView: View {
    private let loading: Bool
    private let image: UIImage?
    private let title: String
    private let titleAddition: String?
    private let subtitle: String?

    init(loading: Bool = false, image: UIImage? = nil, title: String, titleAddition: String? = nil, subtitle: String? = nil) {
        self.loading = loading
        self.image = image
        self.title = title
        self.titleAddition = titleAddition
        self.subtitle = subtitle
    }

    var body: some View {
        HStack(alignment: .center, spacing: Size.Padding.default) {
            ZStack {
                Color.DesignSystem.surfaceCard.frame(
                    width: ManeuverProgressView.topViewImageHeight,
                    height: ManeuverProgressView.topViewImageHeight
                ).opacity(.zero)
                image.map {
                    Image(
                        uiImage: $0.withRenderingMode(.alwaysTemplate)
                    ).resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.DesignSystem.onSurfacePrimary)
                        .frame(height: ManeuverProgressView.topViewImageHeight)
                }
                if loading {
                    ProgressView()
                        .frame(height: ManeuverProgressView.topViewImageHeight)
                }
            }
            VStack(alignment: .leading, spacing: Size.Padding.tiny) {
                HStack(alignment: .firstTextBaseline, spacing: Size.Padding.tiny) {
                    Text(title)
                        .font(.DesignSystem.Headline.large)
                        .foregroundColor(.DesignSystem.onSurfacePrimary)
                    titleAddition.map {
                        Text($0)
                            .font(.DesignSystem.Headline.small)
                            .foregroundColor(.DesignSystem.onSurfaceSecondary)
                    }
                }
                subtitle.map {
                    Text($0)
                        .lineLimit(1)
                        .font(.DesignSystem.Body.large)
                        .foregroundColor(.DesignSystem.onSurfacePrimary)
                }
            }
            Spacer()
        }.transaction { transaction in
            transaction.animation = nil
        }.frame(minWidth: .zero, maxWidth: .infinity)
    }
}
