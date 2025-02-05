import Foundation

final class StaticCameraConfigurationProvider: CameraConfigurationProvider {
    // MARK: Properties

    let cameraConfiguration: CameraConfiguration

    // MARK: Lifecycle

    init(cameraConfiguration: CameraConfiguration = CameraConfiguration()) {
        self.cameraConfiguration = cameraConfiguration
    }
}
