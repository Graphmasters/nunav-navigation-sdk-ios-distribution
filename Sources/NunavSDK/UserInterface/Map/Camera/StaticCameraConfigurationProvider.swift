import Foundation

public final class StaticCameraConfigurationProvider: CameraConfigurationProvider {
    public let cameraConfiguration: CameraConfiguration

    init(cameraConfiguration: CameraConfiguration = CameraConfiguration()) {
        self.cameraConfiguration = cameraConfiguration
    }
}
