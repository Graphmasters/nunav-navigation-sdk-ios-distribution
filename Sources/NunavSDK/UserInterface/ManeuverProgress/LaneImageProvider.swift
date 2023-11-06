import Foundation
import NunavSDKMultiplatform
import UIKit

public protocol LaneImageProvider {
    func getImage(icon: LaneIconProvider.LaneIcon) -> UIImage
}

public class DefaultLaneImageProvider: LaneImageProvider {
    public init() {}

    public func getImage(icon: LaneIconProvider.LaneIcon) -> UIImage {
        switch icon {
        case .right: return Asset.Maneuver.Lane.laneRight.image
        case .left: return Asset.Maneuver.Lane.laneLeft.image
        case .leftUseLeft: return Asset.Maneuver.Lane.laneLeftUseLeft.image
        case .rightUseRight: return Asset.Maneuver.Lane.laneRightUseRight.image
        case .slightLeft: return Asset.Maneuver.Lane.laneSlightLeft.image
        case .slightLeftUseLeft: return Asset.Maneuver.Lane.laneSlightLeftUseLeft.image
        case .slightRight: return Asset.Maneuver.Lane.laneSlightRight.image
        case .slightRightUseRight: return Asset.Maneuver.Lane.laneSlightRightUseRight.image
        case .through: return Asset.Maneuver.Lane.laneThrough.image
        case .throughLeft: return Asset.Maneuver.Lane.laneThroughLeft.image
        case .throughRight: return Asset.Maneuver.Lane.laneThroughRight.image
        case .throughLeftUseLeft: return Asset.Maneuver.Lane.laneThroughLeftUseLeft.image
        case .throughRightUseRight: return Asset.Maneuver.Lane.laneThroughRightUseRight.image
        case .throughRightUseThrough: return Asset.Maneuver.Lane.laneThroughRightUseThrough.image
        case .throughLeftUseThrough: return Asset.Maneuver.Lane.laneThroughLeftUseThrough.image
        case .throughUseThrough: return Asset.Maneuver.Lane.laneThroughUseThrough.image
        }
    }
}
