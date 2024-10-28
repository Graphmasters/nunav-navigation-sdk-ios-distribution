import Foundation
import NunavSDKMultiplatform
import UIKit

extension CameraUpdate.Padding {
    public var edgeInsets: UIEdgeInsets {
        return UIEdgeInsets(
            top: CGFloat(top),
            left: CGFloat(left),
            bottom: CGFloat(bottom),
            right: CGFloat(right)
        )
    }
}
