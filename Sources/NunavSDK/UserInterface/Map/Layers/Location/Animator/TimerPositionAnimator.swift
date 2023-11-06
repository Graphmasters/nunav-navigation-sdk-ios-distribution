import Foundation
import GMCoreUtility
import NunavSDKMultiplatform

public final class TimerPositionAnimatorFactory: PositionAnimatorFactory {
    public init() {}

    public func getPositionAnimator(start: Location, end: Location) -> PositionAnimator {
        TimerPositionAnimator(start: start, end: end)
    }
}

public class TimerPositionAnimator: PositionAnimator {
    private let start: Location
    private let end: Location
    private var duration: TimeInterval = 0.5

    private var animationStartDate = Date()
    private var timer: Timer?

    public weak var delegate: PositionAnimatorDelegate?

    public required init(start: Location, end: Location) {
        self.start = start
        self.end = end
    }

    public func startAnimation(with duration: TimeInterval) {
        self.duration = duration
        animationStartDate = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 0.03334, repeats: true, block: onProgress)
    }

    private func finishAnimation() {
        cancelAnimation()
        delegate?.onUpdate(value: end)
    }

    public func cancelAnimation() {
        timer?.invalidate()
        timer = nil
    }

    private func isAnimating() -> Bool {
        return timer != nil && timer?.isValid == true
    }

    private func onProgress(_: Timer) {
        if Date().timeIntervalSince1970 - animationStartDate.timeIntervalSince1970 < duration,
           isAnimating() {
            let interval = (Date().timeIntervalSince1970 - animationStartDate.timeIntervalSince1970) / duration
            update(with: interval)
        } else {
            finishAnimation()
        }
    }

    private func update(with fraction: Double) {
        let latitude = start.latLng.latitude + (end.latLng.latitude - start.latLng.latitude) * fraction
        let longitude = start.latLng.longitude + (end.latLng.longitude - start.latLng.longitude) * fraction

        let startHeading = Double(truncating: start.heading ?? 0)
        let endHeading = Double(truncating: end.heading ?? 0)

        let delta = (endHeading - startHeading)

        let heading = -180 ... 180 ~= delta
            ? startHeading + delta * fraction
            : (delta > 180 ? startHeading + (delta - 360) * fraction : startHeading + (delta + 360) * fraction)

        let currentValue = Location(
            provider: end.provider,
            timestamp: Date().millisecondsSince1970,
            latLng: LatLng(latitude: latitude, longitude: longitude),
            altitude: end.altitude,
            heading: KotlinDouble(double: heading),
            speed: end.speed,
            accuracy: end.accuracy, level: nil
        )

        delegate?.onUpdate(value: currentValue)
    }
}
