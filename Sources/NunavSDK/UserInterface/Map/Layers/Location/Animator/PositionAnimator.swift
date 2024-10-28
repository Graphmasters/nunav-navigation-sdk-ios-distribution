import Foundation
import NunavSDKMultiplatform

public protocol PositionAnimatorDelegate: AnyObject {
    func onUpdate(value: Location)
}

public protocol PositionAnimator: AnyObject {
    init(start: Location, end: Location)

    var delegate: PositionAnimatorDelegate? { get set }

    func startAnimation(with duration: TimeInterval)
    func cancelAnimation()
}

extension PositionAnimator {
    public func startAnimation() {
        startAnimation(with: 0.55)
    }
}

public protocol PositionAnimatorFactory {
    func getPositionAnimator(start: Location, end: Location) -> PositionAnimator
}
