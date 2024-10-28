import Combine
import Foundation
import NunavDesignSystem
import NunavSDKMultiplatform
import SwiftUI

struct ManeuverProgressView: View {
    // MARK: Static Properties

    static let topViewImageHeight: CGFloat = 48
    static let bottomViewHeight: CGFloat = 36

    // MARK: Properties

    private var viewModel: ManeuverViewModel

    @State private var state: ManeuverUIState

    // MARK: Lifecycle

    init(viewModel: ManeuverViewModel) {
        self.viewModel = viewModel
        self.state = viewModel.state.value
    }

    // MARK: Content

    var body: some View {
        HStack {
            HStack {
                switch onEnum(of: self.state) {
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
        }.onAppear(perform: {
            self.state = self.state
            Task {
                for await state in self.viewModel.state {
                    withAnimation {
                        self.state = state
                    }
                }
            }
        })
    }
}

struct BottomView: View {
    // MARK: Properties

    let secondaryInfo: ManeuverUIStateSecondaryManeuverInfo

    private let defaultLaneIconProvider: DefaultLaneImageProvider = .init()
    private let defaultManeuverIconProvider: DefaultManeuverImageProvider = .init()

    // MARK: Content

    var body: some View {
        Group {
            switch onEnum(of: self.secondaryInfo) {
            case let .laneInfo(laneInfo):
                let icons = laneInfo.laneIcons.map { icon in
                    self.defaultLaneIconProvider.getImage(icon: icon)
                }
                LaneAssistView(laneIcons: icons)
            case let .followingManeuver(followingManeuver):
                FollowingManeuverView(
                    turnIcon: self.defaultManeuverIconProvider.getImage(icon: followingManeuver.maneuverIcon),
                    text: L10n.maneuverProgressViewFollowingManeuverText(followingManeuver.formattedDistance.formattedString())
                )
            }
        }.transaction { transaction in
            transaction.animation = nil
        }
    }
}

struct FollowingManeuverView: View {
    // MARK: Properties

    let turnIcon: UIImage
    let text: String

    // MARK: Content

    var body: some View {
        HStack(spacing: .default) {
            Text(self.text)
                .font(.DesignSystem.Body.large)
                .foregroundColor(.DesignSystem.onSurfacePrimary)
            Image(uiImage: self.turnIcon.withRenderingMode(.alwaysTemplate))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.DesignSystem.onSurfacePrimary)
        }.padding(.tiny)
            .frame(height: ManeuverProgressView.bottomViewHeight)
    }
}

struct LaneAssistView: View {
    // MARK: Properties

    let laneIcons: [UIImage]

    // MARK: Content

    var body: some View {
        HStack(spacing: .zero) {
            ForEach(0 ..< self.laneIcons.count, id: \.self) { index in
                Image(uiImage: self.laneIcons[index].withRenderingMode(.alwaysTemplate))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.DesignSystem.onSurfacePrimary)
            }
        }.padding(.tiny)
            .frame(height: ManeuverProgressView.bottomViewHeight)
    }
}

struct TopLoadingView: View {
    // MARK: Properties

    private let title: String

    // MARK: Lifecycle

    init(title: String) {
        self.title = title
    }

    // MARK: Content

    var body: some View {
        HStack(alignment: .center, spacing: .default) {
            ZStack(alignment: .center) {
                Color.DesignSystem.surfaceCard.frame(
                    width: ManeuverProgressView.topViewImageHeight,
                    height: ManeuverProgressView.topViewImageHeight
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

    // MARK: Content

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
        TopContentView(title: "8", subtitle: "8")
            .opacity(.zero)
    }
}

struct UpcomingManeuverView: View {
    // MARK: Properties

    let state: ManeuverUIStateFollowingRoute

    private let defaultManeuverIconProvider: DefaultManeuverImageProvider = .init()

    // MARK: Content

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
    // MARK: Properties

    private let loading: Bool
    private let image: UIImage?
    private let title: String
    private let titleAddition: String?
    private let subtitle: String?

    // MARK: Lifecycle

    init(loading: Bool = false, image: UIImage? = nil, title: String, titleAddition: String? = nil, subtitle: String? = nil) {
        self.loading = loading
        self.image = image
        self.title = title
        self.titleAddition = titleAddition
        self.subtitle = subtitle
    }

    // MARK: Content

    var body: some View {
        HStack(alignment: .center, spacing: .default) {
            ZStack {
                Color.DesignSystem.surfaceCard.frame(
                    width: ManeuverProgressView.topViewImageHeight,
                    height: ManeuverProgressView.topViewImageHeight
                ).opacity(.zero)
                self.image.map {
                    Image(
                        uiImage: $0.withRenderingMode(.alwaysTemplate)
                    ).resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.DesignSystem.onSurfacePrimary)
                        .frame(height: ManeuverProgressView.topViewImageHeight)
                }
                if self.loading {
                    ProgressView()
                        .frame(height: ManeuverProgressView.topViewImageHeight)
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
                self.subtitle.map {
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
