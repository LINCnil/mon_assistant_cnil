

import Foundation
import Swinject
import HybridNlpEngine

class ModelRelatedAssembly: Assembly {
    private let modelDescription: ModelDescription

    init(modelDescription: ModelDescription) {
        self.modelDescription = modelDescription
    }

    func assemble(container: Container) {
        container.register(SpeechRecognizer.self) { r in
            return DeepspeechRecognizerImplemention(
                modelFileUrl: self.modelDescription.stt.tfModelFileUrl,
                scorerFileUrl: self.modelDescription.stt.scorerFileUrl,
                pipelineLogRepository: r.resolve(PipelineLogRepository.self))
        }.inObjectScope(.modelRelated)

        container.throwsRegister(TextClassifier.self) { r in
            try HybridTextClassifierImplemention(
                modelFileUrl: self.modelDescription.nlp.tfModelFileUrl,
                tokensMapFileUrl: self.modelDescription.nlp.vocabFileUrl,
                stopwordsFileUrl: self.modelDescription.nlp.stopwordsFileUrl,
                keywordsFileUrl: self.modelDescription.nlp.keywordsFileUrl,
                classesMapFileUrl: self.modelDescription.nlp.classesMapFileUrl,
                crunchFileUrl: self.modelDescription.nlp.crunchFileUrl,
                config: self.modelDescription.nlp.config,
                tokenizer: r.resolve(Tokenizer.self)!,
                locale: Locale(identifier: "fr"),
                processLogger: r.resolve(ProcessLogger.self))
        }.inObjectScope(.modelRelated)

        container.register(AnswerRepository.self) { r in
            AnswerRepositoryImplementation(
                questionsDirectory: self.modelDescription.questionsDirectory,
                pipelineLogRepository: r.resolve(PipelineLogRepository.self)
            )
        }.inObjectScope(.container)

        container.throwsRegister(ProcessingService.self) { r in
            ProcessingServiceImplementation(
                bundle: r.resolve(Bundle.self)!,
                speechRecognizer: r.resolve(SpeechRecognizer.self)!,
                textClassifier: try r.throwsResolve(TextClassifier.self),
                answerRepository: r.resolve(AnswerRepository.self)!,
                pipelineLogRepository: r.resolve(PipelineLogRepository.self))
        }.inObjectScope(.modelRelated)
    }
}
