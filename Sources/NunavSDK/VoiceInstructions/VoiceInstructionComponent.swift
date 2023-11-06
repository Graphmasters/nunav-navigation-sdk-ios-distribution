import Foundation
import GMCoreUtility
import NunavSDKMultiplatform

final class VoiceInstructionComponent {
    private let navigationSdk: NavigationSdk
    private let routeDetachStateProvider: RouteDetachStateProvider
    private let locale: Locale

    init(
        navigationSdk: NavigationSdk,
        routeDetachStateProvider: RouteDetachStateProvider,
        locale: Locale = .autoupdatingCurrent
    ) {
        self.navigationSdk = navigationSdk
        self.routeDetachStateProvider = routeDetachStateProvider
        self.locale = locale
    }

    var enabled: Bool {
        get {
            voiceInstructionHandler.enabled
        }
        set {
            voiceInstructionHandler.enabled = newValue
        }
    }

    private lazy var voiceInstructionStringGenerator: VoiceInstructionStringGenerator = LocaleVoiceInstructionStringGenerator(
        localeProvider: FoundationLanguageProvider()
    )

    private lazy var voiceInstructionDispatcher: VoiceInstructionDispatcher = AudioPlayerVoiceInstructionDispatcher(
        audioJobPlayer: audioComponent.audioJobPlayer,
        voiceAudioJobProvider: audioComponent.voiceAudioJobProvider
    )

    private lazy var voiceInstructionHandler: VoiceInstructionHandler = NavigationVoiceInstructionHandler(
        navigationSdk: navigationSdk,
        voiceInstructionStringGenerator: voiceInstructionStringGenerator,
        voiceInstructionDispatcher: voiceInstructionDispatcher,
        detachStateProvider: routeDetachStateProvider
    )

    private lazy var audioComponent = AudioComponent()
}
