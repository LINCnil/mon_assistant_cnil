import Foundation
import AVFoundation

class AVSpeechSynthesizerImplementation: SpeechSynthesizer {
    fileprivate class DelegateImplementation: NSObject, AVSpeechSynthesizerDelegate {
        weak var owner: AVSpeechSynthesizerImplementation?
        func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
            guard let owner = owner else { return }
            owner.onSpeakCompleted?()
            owner.isManuallyCanceling = false
        }

        func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        }

        func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
            guard let owner = owner else { return }
            if !owner.isManuallyCanceling {
                owner.onSpeakCompleted?()
            }
            owner.isManuallyCanceling = false
        }
    }

    private let synthesizer: AVSpeechSynthesizer
    private var isManuallyCanceling: Bool = false
    private var delegateHolder: DelegateImplementation
    var onSpeakCompleted: (() -> Void)?

    var isSpeaking: Bool { synthesizer.isSpeaking }
    var isPaused: Bool { synthesizer.isPaused }

    init() {
        self.delegateHolder = DelegateImplementation()
        self.synthesizer = AVSpeechSynthesizer()
        self.synthesizer.delegate = delegateHolder
        self.delegateHolder.owner = self
    }

    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        speak(utterance)
    }

    func speak(_ attributedText: NSAttributedString) {
        let utterance = AVSpeechUtterance(attributedString: attributedText)
        speak(utterance)
    }

    func stopSpeaking() {
        if synthesizer.stopSpeaking(at: .immediate) {
            isManuallyCanceling = true
        }
    }

    func continueSpeaking() {
        synthesizer.continueSpeaking()
    }

    func pauseSpeaking() {
        synthesizer.pauseSpeaking(at: .immediate)
    }

    private func speak(_ utterance: AVSpeechUtterance) {
        let selectedGender = ApplicationSettings.shared.speechVoiceGender
        let gender: AVSpeechSynthesisVoiceGender = selectedGender == .male ? .male : .female
        let voice = AVSpeechSynthesisVoice.speechVoices().first(where: { $0.language == "fr-FR" && $0.gender == gender})
        utterance.voice = voice
        synthesizer.speak(utterance)
    }
}
