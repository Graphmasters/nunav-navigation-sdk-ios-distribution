import Foundation
import MultiplatformNavigation

protocol PositionAnimatorDelegate: AnyObject {
    func onUpdate(value: Location)
}

protocol PositionAnimator: AnyObject {
    init(start: Location, end: Location)

    var delegate: PositionAnimatorDelegate? { get set }

    func startAnimation(with duration: TimeInterval)
    func cancelAnimation()
}

extension PositionAnimator {
    func startAnimation() {
        startAnimation(with: 0.55)
    }
}

protocol PositionAnimatorFactory {
    func getPositionAnimator(start: Location, end: Location) -> PositionAnimator
}
