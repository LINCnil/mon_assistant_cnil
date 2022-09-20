
import Foundation
import Swinject
import NaturalLanguage
import HybridNlpEngine

class HandlersAssembly: Assembly {
    func assemble(container: Container) {
        container.register(Bundle.self) { _ in
            Bundle.main
        }.inObjectScope(.container)

        container.register(ProcessLogger.self) { r in
            NLPProcessLoggerImplementation(pipelineLogRepository: r.resolve(PipelineLogRepository.self)!)
        }.inObjectScope(.container)

        container.register(Tokenizer.self) { _ in
            NLTokenizerImplemention(language: NLLanguage.french)
        }.inObjectScope(.container)
    }
}
