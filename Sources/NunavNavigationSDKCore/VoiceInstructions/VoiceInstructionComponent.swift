import AVFoundation
import Foundation
import GMCoreUtility
import MultiplatformNavigation

public final class VoiceInstructionComponent {
    // MARK: Properties

    private let navigationSdk: NavigationSdk
    private let routeDetachStateProvider: RouteDetachStateProvider
    private let locale: Locale

    private lazy var voiceInstructionStringGenerator: VoiceInstructionStringGenerator = LocaleVoiceInstructionStringGenerator(
        localeProvider: FoundationLanguageProvider()
    )

    private lazy var voiceInstructionDispatcher: VoiceInstructionDispatcher = AudioPlayerVoiceInstructionDispatcher(
        audioJobPlayer: audioJobPlayer,
        voiceAudioJobProvider: voiceAudioJobProvider
    )

    private lazy var voiceInstructionHandler: VoiceInstructionHandler = NavigationVoiceInstructionHandler(
        navigationSdk: navigationSdk,
        voiceInstructionStringGenerator: voiceInstructionStringGenerator,
        voiceInstructionDispatcher: voiceInstructionDispatcher,
        detachStateProvider: routeDetachStateProvider
    )

    private lazy var voiceAudioJobProvider: VoiceAudioJobProvider = SynthesizingVoiceAudioJobProvider()

    private lazy var audioJobPlayer: AudioJobPlayer = QueuingAudioJobPlayer(delegate: nil)

    // MARK: Computed Properties

    var enabled: Bool {
        get {
            voiceInstructionHandler.enabled
        }
        set {
            guard voiceInstructionHandler.enabled != newValue else {
                return
            }
            voiceInstructionHandler.enabled = newValue

            if !newValue {
                audioJobPlayer.cancelAudioJobs()
            }
        }
    }

    // MARK: Lifecycle

    public init(
        navigationSdk: NavigationSdk,
        routeDetachStateProvider: RouteDetachStateProvider,
        locale: Locale = .autoupdatingCurrent
    ) {
        self.navigationSdk = navigationSdk
        self.routeDetachStateProvider = routeDetachStateProvider
        self.locale = locale
    }
}
