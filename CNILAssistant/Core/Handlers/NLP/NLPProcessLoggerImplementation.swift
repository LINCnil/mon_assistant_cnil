import Foundation
import HybridNlpEngine

final class NLPProcessLoggerImplementation: ProcessLogger {
    let pipelineLogRepository: PipelineLogRepository

    init(pipelineLogRepository: PipelineLogRepository) {
        self.pipelineLogRepository = pipelineLogRepository
    }

    func log(entry: String) {
        pipelineLogRepository.log(entry: entry, for: .nlp)
    }
}
