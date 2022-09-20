

import Foundation
import HybridNlpEngine

final class ProcessingServiceImplementation: ProcessingService {
    private let answerRepository: AnswerRepository
    private let textClassifier: TextClassifier
    private let speechRecognizer: SpeechRecognizer

    private let pipelineLogRepository: PipelineLogRepository?

    private let bundle: Bundle

    init(bundle: Bundle,
         speechRecognizer: SpeechRecognizer,
         textClassifier: TextClassifier,
         answerRepository: AnswerRepository,
         pipelineLogRepository: PipelineLogRepository?) {
        self.bundle = bundle
        self.speechRecognizer = speechRecognizer
        self.textClassifier = textClassifier
        self.answerRepository = answerRepository
        self.pipelineLogRepository = pipelineLogRepository
    }

    func processData(dataSource: DataSource, completion: @escaping (Result<Answer, Error>) -> Void) {
        pipelineLogRepository?.log(entry: "start processing", for: .common)
        performSpeechRecognition(dataSource: dataSource) { speechResult in
            speechResult.asyncMap(transform: self.performClassification) {
                $0.asyncMap(transform: self.performProcessingClassifierResult) {
                    $0.asyncMap(transform: self.performGettingAnswer) {
                        $0.asyncMap(transform: { answers, completion in
                            self.pipelineLogRepository?.log(entry: "success", for: .common)
                            completion(.success(Answer(userQuestion: (try? speechResult.get()) ?? "", proposals: answers)))
                        }, completion: completion)
                    }
                }
            }
        }
    }

    private func performProcessingClassifierResult(classificationResult: [Int],
                                                   completion: @escaping (Result<[Int], Error>) -> Void) {
        let result: Result<[Int], Error>

        defer {
            DispatchQueue.main.async {
                completion(result)
            }
        }

        if classificationResult.isEmpty {
            result = .failure(PipelineError.unexpectedClassifierResult)
        } else {
            result = .success(classificationResult)
        }
    }

    private func performGettingAnswer(answerIds: [Int], completion: @escaping (Result<[AnswerContent], Error>) -> Void) {
        pipelineLogRepository?.log(entry: "quering answers for ids: \(answerIds)", for: .db)
        answerRepository.getAnswers(for: answerIds, completion: completion)
    }

    private func performSpeechRecognition(dataSource: DataSource, completion: @escaping (Result<String, Error>) -> Void) {
        switch dataSource {
        case .audioFile(let url):
            speechRecognizer.recognizeAudio(url: url, completion: completion)
        case .text(let text):
            pipelineLogRepository?.log(entry: "skip stt, manual input is used: \"\(text)\"", for: .common)
            DispatchQueue.main.async {
                completion(.success(text))
            }
        }
    }

    private func performClassification(text: String, completion: @escaping (Result<[Int], Error>) -> Void) {
        textClassifier.classify(text: text, completion: completion)
    }
}
