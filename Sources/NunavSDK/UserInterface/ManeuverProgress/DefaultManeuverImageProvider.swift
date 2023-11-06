import Foundation
import NunavSDKMultiplatform
import UIKit

public class DefaultManeuverImageProvider: ManeuverImageProvider {
    public init() {}

    public func getImageByTurnInfo(turnInfo: TurnInfo?) -> UIImage {
        getImage(icon: ManeuverIconProvider.shared.getManeuverIcon(turnInfo: turnInfo))
    }

    public func getImage(icon: ManeuverIconProvider.ManeuverIcon) -> UIImage {
        switch icon {
        case .arriveStraight: return Asset.Maneuver.Turn.icTurnCommandArriveStraight.image
        case .continueLeft: return Asset.Maneuver.Turn.icTurnCommandContinueLeft.image
        case .continueSharpLeft: return Asset.Maneuver.Turn.icTurnCommandContinueSharpLeft.image
        case .continueSharpRight: return Asset.Maneuver.Turn.icTurnCommandContinueSharpRight.image
        case .continueSlightLeft: return Asset.Maneuver.Turn.icTurnCommandContinueSlightleft.image
        case .continueSlightRight: return Asset.Maneuver.Turn.icTurnCommandContinueSlightright.image
        case .continueStraight: return Asset.Maneuver.Turn.icTurnCommandContinueStraight.image
        case .continueRight: return Asset.Maneuver.Turn.icTurnCommandContinueRight.image
        case .departStraight: return Asset.Maneuver.Turn.icTurnCommandDepartStraight.image
        case .endOfRoadLeft: return Asset.Maneuver.Turn.icTurnCommandEndofroadLeft.image
        case .endOfRoadRight: return Asset.Maneuver.Turn.icTurnCommendEndofroadRight.image
        case .forkSlightLeft: return Asset.Maneuver.Turn.icTurnCommandForkSlightleft.image
        case .forkSlightRight: return Asset.Maneuver.Turn.icTurnCommandForkSlightright.image
        case .rampLevelDown: return Asset.Maneuver.Turn.icTurnCommandRampDown.image
        case .rampLevelUp: return Asset.Maneuver.Turn.icTurnCommandRampUp.image
        case .roundaboutSharpLeft: return Asset.Maneuver.Turn.icTurnCommandRotaryRhtSharpleft.image
        case .roundaboutLeft: return Asset.Maneuver.Turn.icTurnCommandRotaryRhtLeft.image
        case .roundaboutSlightLeft: return Asset.Maneuver.Turn.icTurnCommandRotaryRhtSlightleft.image
        case .roundaboutStraight: return Asset.Maneuver.Turn.icTurnCommandRotaryRhtStraight.image
        case .roundaboutSlightRight: return Asset.Maneuver.Turn.icTurnCommandRotaryRhtSlightright.image
        case .roundaboutRight: return Asset.Maneuver.Turn.icTurnCommandRotaryRhtRight.image
        case .roundaboutSharpRight: return Asset.Maneuver.Turn.icTurnCommandRotaryRhtSharpright.image
        case .roundaboutRht: return Asset.Maneuver.Turn.icTurnCommandRotaryRht.image
        case .uturnRht: return Asset.Maneuver.Turn.icTurnCommandUTurnRht.image
        default:
            return Asset.Maneuver.Turn.icTurnCommandContinueStraight.image
        }
    }
}
