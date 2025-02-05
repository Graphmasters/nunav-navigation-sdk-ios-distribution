import Foundation
import MultiplatformNavigation
import UIKit

extension ManeuverIconProvider.ManeuverIcon {
    static func image(for maneuverIcon: ManeuverIconProvider.ManeuverIcon) -> UIImage {
        switch maneuverIcon {
        case .arriveStraight: return UIImage.Maneuver.Turn.icTurnCommandArriveStraight
        case .continueLeft: return UIImage.Maneuver.Turn.icTurnCommandContinueLeft
        case .continueSharpLeft: return UIImage.Maneuver.Turn.icTurnCommandContinueSharpLeft
        case .continueSharpRight: return UIImage.Maneuver.Turn.icTurnCommandContinueSharpRight
        case .continueSlightLeft: return UIImage.Maneuver.Turn.icTurnCommandContinueSlightleft
        case .continueSlightRight: return UIImage.Maneuver.Turn.icTurnCommandContinueSlightright
        case .continueStraight: return UIImage.Maneuver.Turn.icTurnCommandContinueStraight
        case .continueRight: return UIImage.Maneuver.Turn.icTurnCommandContinueRight
        case .departStraight: return UIImage.Maneuver.Turn.icTurnCommandDepartStraight
        case .endOfRoadLeft: return UIImage.Maneuver.Turn.icTurnCommandEndofroadLeft
        case .endOfRoadRight: return UIImage.Maneuver.Turn.icTurnCommendEndofroadRight
        case .forkSlightLeft: return UIImage.Maneuver.Turn.icTurnCommandForkSlightleft
        case .forkSlightRight: return UIImage.Maneuver.Turn.icTurnCommandForkSlightright
        case .rampLevelDown: return UIImage.Maneuver.Turn.icTurnCommandRampDown
        case .rampLevelUp: return UIImage.Maneuver.Turn.icTurnCommandRampUp
        case .roundaboutSharpLeft: return UIImage.Maneuver.Turn.icTurnCommandRotaryRhtSharpleft
        case .roundaboutLeft: return UIImage.Maneuver.Turn.icTurnCommandRotaryRhtLeft
        case .roundaboutSlightLeft: return UIImage.Maneuver.Turn.icTurnCommandRotaryRhtSlightleft
        case .roundaboutStraight: return UIImage.Maneuver.Turn.icTurnCommandRotaryRhtStraight
        case .roundaboutSlightRight: return UIImage.Maneuver.Turn.icTurnCommandRotaryRhtSlightright
        case .roundaboutRight: return UIImage.Maneuver.Turn.icTurnCommandRotaryRhtRight
        case .roundaboutSharpRight: return UIImage.Maneuver.Turn.icTurnCommandRotaryRhtSharpright
        case .roundaboutRht: return UIImage.Maneuver.Turn.icTurnCommandRotaryRht
        case .uturnRht: return UIImage.Maneuver.Turn.icTurnCommandUTurnRht
        default:
            return UIImage.Maneuver.Turn.icTurnCommandContinueStraight
        }
    }
}
