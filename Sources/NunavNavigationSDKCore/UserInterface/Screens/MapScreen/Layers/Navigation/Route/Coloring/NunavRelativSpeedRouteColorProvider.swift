import Foundation
import GMCoreUtility
import MultiplatformNavigation
import UIKit

final class NunavRelativSpeedRouteColorProvider: RelativeSpeedRouteFeatureCreatorColorProvider {
    // MARK: Properties

    lazy var `default`: String = hexStringFromColor(color: .blue)

    lazy var outline: String = hexStringFromColor(color: .blue)

    private let userInterfaceStyle: UIUserInterfaceStyle

    private lazy var lightYellow = UIColor.yellow

    private lazy var darkYellow = UIColor.yellow

    // MARK: Computed Properties

    var red: String {
        return UIColor.red.hexString
    }

    var yellow: String {
        return UIColor.yellow.hexString
    }

    // MARK: Lifecycle

    init(userInterfaceStyle: UIUserInterfaceStyle) {
        self.userInterfaceStyle = userInterfaceStyle
    }

    // MARK: Functions

    private func hexStringFromColor(color: UIColor) -> String {
        let components = color.cgColor.components
        let red: CGFloat = components?[0] ?? 0.0
        let green: CGFloat = components?[1] ?? 0.0
        let blue: CGFloat = components?[2] ?? 0.0

        return String(format: "#%02lX%02lX%02lX",
                      lroundf(Float(red * 255)), lroundf(Float(green * 255)), lroundf(Float(blue * 255)))
    }
}
