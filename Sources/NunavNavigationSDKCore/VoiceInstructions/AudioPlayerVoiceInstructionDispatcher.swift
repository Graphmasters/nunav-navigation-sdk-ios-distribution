import Foundation
import GMCoreUtility
import MultiplatformNavigation

final class AudioPlayerVoiceInstructionDispatcher: VoiceInstructionDispatcher {
    // MARK: Properties

    private let audioJobPlayer: AudioJobPlayer
    private let voiceAudioJobProvider: VoiceAudioJobProvider

    // MARK: Lifecycle

    init(
        audioJobPlayer: AudioJobPlayer,
        voiceAudioJobProvider: VoiceAudioJobProvider
    ) {
        self.audioJobPlayer = audioJobPlayer
        self.voiceAudioJobProvider = voiceAudioJobProvider
    }

    // MARK: Functions

    func dispatch(
        voiceInstructionContext _: VoiceInstructionContext,
        voiceInstructionText: String,
        balance _: Float,
        onDone: @escaping (String) -> Void
    ) {
        audioJobPlayer.execute(audioJob: voiceAudioJobProvider.audioJob(for: voiceInstructionText), completion: {
            onDone(voiceInstructionText)
        })
    }
}
