import Foundation
import GMCoreUtility
import NunavSDKMultiplatform
import UIKit

public final class NunavRelativSpeedRouteColorProvider: RelativeSpeedRouteFeatureCreatorColorProvider {
    private let userInterfaceStyle: UIUserInterfaceStyle

    public init(userInterfaceStyle: UIUserInterfaceStyle) {
        self.userInterfaceStyle = userInterfaceStyle
    }

    public lazy var `default`: String = hexStringFromColor(color: .blue)

    public lazy var outline: String = hexStringFromColor(color: .blue)

    public var red: String {
        return UIColor.red.hexString
    }

    private lazy var lightYellow = UIColor.yellow

    private lazy var darkYellow = UIColor.yellow

    public var yellow: String {
        return UIColor.yellow.hexString
    }

    private func hexStringFromColor(color: UIColor) -> String {
        let components = color.cgColor.components
        let red: CGFloat = components?[0] ?? 0.0
        let green: CGFloat = components?[1] ?? 0.0
        let blue: CGFloat = components?[2] ?? 0.0

        return String(format: "#%02lX%02lX%02lX",
                      lroundf(Float(red * 255)), lroundf(Float(green * 255)), lroundf(Float(blue * 255)))
    }
}
