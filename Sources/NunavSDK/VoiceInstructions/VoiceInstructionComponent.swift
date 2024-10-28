import AVFoundation
import Foundation
import GMCoreUtility
import NunavSDKMultiplatform

final class VoiceInstructionComponent {
    // MARK: Nested Types

    private final class Settings: NSObject, AudioSettings {
        var isAudioEnabled: Bool = false
    }

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

    private lazy var audioJobPlayer: AudioJobPlayer = QueuingAudioJobPlayer(
        audioSettings: Settings(),
        audioController: audioController
    )

    private lazy var speechSynthesizer: AVSpeechSynthesizer = .init()

    private lazy var audioController: AudioController = InterceptingAudioController(
        audioSession: AVAudioSession.sharedInstance(),
        interceptors: [],
        audioSessionInfoProvider: AVAudioSessionInfoProvider(
            audioSession: AVAudioSession.sharedInstance()
        ),
        audioSessionConfigurationProvider: NavigationAudioSessionConfigProvider()
    )

    // MARK: Computed Properties

    var enabled: Bool {
        get {
            voiceInstructionHandler.enabled
        }
        set {
            voiceInstructionHandler.enabled = newValue
        }
    }

    // MARK: Lifecycle

    init(
        navigationSdk: NavigationSdk,
        routeDetachStateProvider: RouteDetachStateProvider,
        locale: Locale = .autoupdatingCurrent
    ) {
        self.navigationSdk = navigationSdk
        self.routeDetachStateProvider = routeDetachStateProvider
        self.locale = locale
    }
}
