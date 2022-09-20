
import Foundation

enum PipelineError: Error {
    case unexpectedClassifierResult
}

extension PipelineError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .unexpectedClassifierResult:
            return "Unexpected result of classification"
        }
    }
}
