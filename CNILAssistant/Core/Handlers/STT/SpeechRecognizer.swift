import Foundation

protocol SpeechRecognizer {
    func recognizeAudio(url: URL, completion: @escaping (Result<String, Error>) -> Void)
}
