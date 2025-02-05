import Foundation
import MultiplatformNavigation
import UIKit

extension CameraUpdate.Padding {
    var edgeInsets: UIEdgeInsets {
        return UIEdgeInsets(
            top: CGFloat(top),
            left: CGFloat(left),
            bottom: CGFloat(bottom),
            right: CGFloat(right)
        )
    }
}
