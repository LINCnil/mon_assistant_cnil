import Foundation
import HybridNlpEngine

extension ClassifierError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .fileNotFound(filename):
            return "Nlp model supporting file not found \(filename)"
        case let .invalidFileFormat(filename):
            return "Nlp model supporting file has invalid format \(filename)"
        case let .invalidCountOfClasses(count, expeted):
            return "Invalid count of classes \(count), expected \(expeted)"
        case let .unexpectedClassIndex(index):
            return "Unexpected index of class name \(index)"
        case .invalidClassName:
            return "Invalid class name"
        case .noWordsInText:
            return "No speech found"
        case .noResults:
            return "OOT threshold not reached"
        @unknown default:
            fatalError("Unknow Classifier Error")
        }
    }
}
