import Foundation

enum SpeechSynthesizerVoiceGender: Int {
    case male = 1
    case female = 2
}

protocol SpeechSynthesizer {
    var isSpeaking: Bool { get }
    var isPaused: Bool { get }
    var onSpeakCompleted: (() -> Void)? { get set }
    func speak(_ text: String)
    func speak(_ attributedText: NSAttributedString)
    func stopSpeaking()
    func pauseSpeaking()
    func continueSpeaking()
}
