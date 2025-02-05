import CoreLocation
import Foundation
import GMMapUtility
import Mapbox
import MultiplatformNavigation

extension MGLMapViewCameraController {
    // MARK: Nested Types

    private enum Constants {
        static let maxTilt: CGFloat = 55
        static let zoomFactorLandscape: Double = -1
        static let tiltFactorLandscape: CGFloat = 0.7
    }

    // MARK: Functions

    func move(cameraUpdate: CameraUpdate, cameraConfiguration: CameraConfiguration) {
        move(
            to: CLLocationCoordinate2D(
                latitude: cameraUpdate.latLng.latitude,
                longitude: cameraUpdate.latLng.longitude
            ),
            heading: heading(for: cameraUpdate, cameraConfiguration: cameraConfiguration),
            duration: convert(duration(for: cameraUpdate)),
            zoom: zoom(for: cameraUpdate, cameraConfiguration: cameraConfiguration),
            pitch: tilt(for: cameraUpdate, cameraConfiguration: cameraConfiguration),
            edgeInsets: convert(padding(for: cameraUpdate, cameraConfiguration: cameraConfiguration)),
            completion: nil
        )
    }

    private func convert(_ duration: Duration) -> TimeInterval {
        Double(truncating: duration.inWholeMilliseconds() as NSNumber) / 1000.0
    }

    private func duration(for cameraUpdate: CameraUpdate) -> Duration {
        guard let duration = cameraUpdate.duration else {
            return .companion.ZERO
        }
        return duration
    }

    private func heading(for cameraUpdate: CameraUpdate, cameraConfiguration: CameraConfiguration) -> Double? {
        switch cameraConfiguration.perspective {
        case .threeDimensional, .twoDimensional:
            return cameraUpdate.bearing?.doubleValue
        case .twoDimensionalNorth:
            return 0
        }
    }

    private func padding(for cameraUpdate: CameraUpdate, cameraConfiguration: CameraConfiguration) -> CameraUpdate.Padding {
        switch cameraConfiguration.perspective {
        case .threeDimensional, .twoDimensional:
            return cameraUpdate.padding
        case .twoDimensionalNorth:
            return CameraUpdate.Padding(left: .zero, top: .zero, right: .zero, bottom: .zero)
        }
    }

    private func zoom(for cameraUpdate: CameraUpdate, cameraConfiguration: CameraConfiguration) -> Double? {
        switch cameraConfiguration.perspective {
        case .threeDimensional, .twoDimensional, .twoDimensionalNorth:
            return cameraUpdate.zoom.map {
                $0.doubleValue
                    + Double(cameraConfiguration.zoomLevelOffset)
            }
        }
    }

    private func tilt(for cameraUpdate: CameraUpdate, cameraConfiguration: CameraConfiguration) -> CGFloat? {
        switch cameraConfiguration.perspective {
        case .threeDimensional:
            return cameraUpdate.tilt.map {
                min(CGFloat(truncating: $0.doubleValue as NSNumber), Constants.maxTilt)
                    * cameraConfiguration.tiltFactor
            }
        case .twoDimensional, .twoDimensionalNorth:
            return .zero
        }
    }

    private func convert(_ padding: CameraUpdate.Padding) -> UIEdgeInsets {
        return UIEdgeInsets(
            top: CGFloat(padding.top),
            left: CGFloat(padding.left),
            bottom: CGFloat(padding.bottom),
            right: CGFloat(padding.right)
        )
    }
}
