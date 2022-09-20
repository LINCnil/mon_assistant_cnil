

import Foundation

enum AnswerRepositoryError: Error {
    case fileNotFound(name: String)
    case invalidFormat(name: String, inner: Error?)
}

extension AnswerRepositoryError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .fileNotFound(filename):
            return "Answer file not found for \(filename)"
        case let .invalidFormat(filename, _):
            return "Invalid format of JSON for \(filename)"
        }
    }
}
