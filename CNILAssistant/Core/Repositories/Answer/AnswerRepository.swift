
import Foundation

protocol AnswerRepository {
    func getAnswers(for answerIds: [Int], completion: @escaping (Result<[AnswerContent], Error>) -> Void)
}
