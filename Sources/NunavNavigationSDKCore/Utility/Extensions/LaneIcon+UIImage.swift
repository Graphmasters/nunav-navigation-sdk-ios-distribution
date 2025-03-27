import Foundation
import MultiplatformNavigation
import UIKit

extension LaneIcon {
    static func image(for icon: LaneIcon) -> UIImage {
        switch icon {
        case .laneRight: return UIImage.Maneuver.Lane.laneRight
        case .laneLeft: return UIImage.Maneuver.Lane.laneLeft
        case .laneLeftUseLeft: return UIImage.Maneuver.Lane.laneLeftUseLeft
        case .laneRightUseRight: return UIImage.Maneuver.Lane.laneRightUseRight
        case .laneSlightLeft: return UIImage.Maneuver.Lane.laneSlightLeft
        case .laneSlightLeftUseSlightLeft: return UIImage.Maneuver.Lane.laneSlightLeftUseLeft
        case .laneSlightRight: return UIImage.Maneuver.Lane.laneSlightRight
        case .laneSlightRightUseSlightRight: return UIImage.Maneuver.Lane.laneSlightRightUseRight
        case .laneThrough: return UIImage.Maneuver.Lane.laneThrough
        case .laneThroughLeft: return UIImage.Maneuver.Lane.laneThroughLeft
        case .laneThroughRight: return UIImage.Maneuver.Lane.laneThroughRight
        case .laneThroughLeftUseLeft: return UIImage.Maneuver.Lane.laneThroughLeftUseLeft
        case .laneThroughRightUseRight: return UIImage.Maneuver.Lane.laneThroughRightUseRight
        case .laneThroughRightUseThrough: return UIImage.Maneuver.Lane.laneThroughRightUseThrough
        case .laneThroughLeftUseThrough: return UIImage.Maneuver.Lane.laneThroughLeftUseThrough
        case .laneThroughUseThrough: return UIImage.Maneuver.Lane.laneThroughUseThrough
        default: return UIImage.Maneuver.Lane.laneThroughUseThrough
        }
    }
}
