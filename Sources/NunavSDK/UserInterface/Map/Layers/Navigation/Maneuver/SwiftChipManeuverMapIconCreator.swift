import NunavSDKMultiplatform
import UIKit

class SwiftChipManeuverMapIconCreator: ManeuverMapIconCreator {
    private let maneuverImageProvider: ManeuverImageProvider
    private let viewImageRenderer: ViewImageRenderer

    init(
        maneuverImageProvider: ManeuverImageProvider,
        viewImageRenderer: ViewImageRenderer = PlainViewImageRenderer()
    ) {
        self.maneuverImageProvider = maneuverImageProvider
        self.viewImageRenderer = viewImageRenderer
    }

    override func create(turnInfo: TurnInfo, showDirectionLabel: Bool) -> ManeuverMapIcon? {
        if isDisplayable(turnInfo: turnInfo) {
            return createManeuverMapIcon(turnInfo, showDirectionLabel, getIconAnchor(turnCommand: turnInfo.turnCommand))
        }
        return nil
    }

    private func createManeuverMapIcon(_ turnInfo: TurnInfo, _ showDirectionLabel: Bool, _ anchor: String) -> ManeuverMapIcon? {
        return createImage(turnInfo, showDirectionLabel, anchor).map {
            ManeuverMapIcon(image: $0, anchor: anchor)
        }
    }

    private func createImage(_ turnInfo: TurnInfo, _ showDirectionLabel: Bool, _ anchor: String) -> UIImage? {
        let view = createView(turnInfo, showDirectionLabel, anchor)
        view.initialize()
        return viewImageRenderer.render(view: view)
    }

    private func createView(_ turnInfo: TurnInfo, _ showDirectionLabel: Bool, _ anchor: String) -> ChipManeuverIconView {
        let label: String? = showDirectionLabel ? TurnInfoUtils.shared.getTurnInfoLabel(turnInfo: turnInfo) : nil
        return ChipManeuverIconView(
            turnIcon: maneuverImageProvider.getImageByTurnInfo(turnInfo: turnInfo),
            directionLabel: label,
            anchor: anchor,
            factor: 1.0
        )
    }

    private class ChipManeuverIconView: UIView {
        private let turnIcon: UIImage
        private let directionLabel: String?
        private let anchor: String
        private let factor: CGFloat

        private var label: UILabel!
        private var imageView: UIImageView!
        private var contentStack: UIStackView!

        init(turnIcon: UIImage, directionLabel: String?, anchor: String, factor: CGFloat) {
            self.turnIcon = turnIcon
            self.directionLabel = directionLabel
            self.anchor = anchor
            self.factor = factor
            super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func initialize() {
            initBackground()
            initIcon()
            initLabel()
            initStack()
            initLayout()

            refreshContent()

            layoutIfNeeded()

            applyBorder()
        }

        private func initBackground() {
            backgroundColor = .DesignSystem.surfacePrimary.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark))
            translatesAutoresizingMaskIntoConstraints = false
        }

        private func initLabel() {
            label = UILabel()
            label.font = UIFont.systemFont(ofSize: 17.0)
            label.textColor = .white
            label.translatesAutoresizingMaskIntoConstraints = false
        }

        private func initIcon() {
            imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFit
            imageView.tintColor = .white
        }

        private func initStack() {
            contentStack = getCurrentContentStackView()
            contentStack.translatesAutoresizingMaskIntoConstraints = false
            contentStack.spacing = 6.0
            contentStack.alignment = .center
            contentStack.alpha = 0.95
        }

        private func getCurrentContentStackView() -> UIStackView {
            if directionLabel == nil {
                return UIStackView(arrangedSubviews: [imageView])
            }
            return anchor == "bottom-left"
                ? UIStackView(arrangedSubviews: [imageView, label])
                : UIStackView(arrangedSubviews: [label, imageView])
        }

        private func initLayout() {
            addSubview(contentStack)
            NSLayoutConstraint.activate([
                contentStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8.0 * factor),
                contentStack.topAnchor.constraint(equalTo: topAnchor, constant: 8.0 * factor),
                contentStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8.0 * factor),
                contentStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8.0 * factor)
            ])

            NSLayoutConstraint.activate([
                imageView.heightAnchor.constraint(equalToConstant: 20.0 * factor),
                imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor)
            ])

            if label.superview != nil {
                NSLayoutConstraint.activate([
                    label.heightAnchor.constraint(equalTo: imageView.heightAnchor),
                    label.widthAnchor.constraint(lessThanOrEqualToConstant: 200.0 * factor)
                ])
            }
        }

        private func refreshContent() {
            label.text = directionLabel
            imageView.image = turnIcon
        }

        private func applyBorder() {
            let mask = getMask()
            layer.mask = mask

            let borderLayer = CAShapeLayer()
            borderLayer.path = mask.path
            borderLayer.lineWidth = 1.0
            borderLayer.strokeColor = UIColor.white.cgColor
            borderLayer.fillColor = UIColor.clear.cgColor
            borderLayer.frame = bounds

            layer.addSublayer(borderLayer)
        }

        private func getMask() -> CAShapeLayer {
            let height = bounds.size.height
            let path = UIBezierPath(
                roundedRect: bounds,
                byRoundingCorners: roundedCornersFor(anchor),
                cornerRadii: CGSize(width: height / 2, height: height / 2)
            )
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            return mask
        }

        private func roundedCornersFor(_ anchor: String) -> UIRectCorner {
            return anchor == "bottom-left"
                ? [.topLeft, .topRight, .bottomRight]
                : [.topLeft, .topRight, .bottomLeft]
        }
    }
}
