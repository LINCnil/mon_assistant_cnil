
import Foundation

final class AnswerRepositoryImplementation: AnswerRepository {
    private let questionsDirectory: URL
    private let pipelineLogRepository: PipelineLogRepository?

    init(questionsDirectory: URL, pipelineLogRepository: PipelineLogRepository?) {
        self.questionsDirectory = questionsDirectory
        self.pipelineLogRepository = pipelineLogRepository
    }

    // MARK: - AnswerRepository

    func getAnswers(for answerIds: [Int], completion: @escaping (Result<[AnswerContent], Error>) -> Void) {
        DispatchQueue.global().async {
            let result: Result<[AnswerContent], Error>

            defer {
                DispatchQueue.main.async {
                    completion(result)
                }
            }

            do {
                result = .success(try answerIds.map { id in try self.getAnswer(for: id) })
            } catch {
                result = .failure(error)
                return
            }
        }
    }

    // MARK: - Private

    private func getAnswer(for answerId: Int) throws -> AnswerContent {
        let answerFileName = self.makeAnswerFilename(for: answerId)
        let answerUrl = questionsDirectory.appendingPathComponent("\(answerFileName).json")
        if !FileManager.default.fileExists(at: answerUrl) {
            throw AnswerRepositoryError.fileNotFound(name: answerFileName)
        }

        let questionFileName = self.makeQuestionFilename(for: answerId)
        let questionUrl = questionsDirectory.appendingPathComponent("\(questionFileName).json")
        if !FileManager.default.fileExists(at: questionUrl) {
            throw AnswerRepositoryError.fileNotFound(name: questionFileName)
        }

        let answerDto: AnswerDto
        let questionDto: QuestionDto

        do {
            answerDto = try self.decodeJSON(AnswerDto.self, located: answerUrl)
        } catch {
            throw AnswerRepositoryError.invalidFormat(name: answerFileName, inner: error)
        }

        do {
            questionDto = try self.decodeJSON(QuestionDto.self, located: questionUrl)
        } catch {
            throw AnswerRepositoryError.invalidFormat(name: answerFileName, inner: error)
        }

        return try AnswerMapper().map(answerDto: answerDto, questionDto: questionDto)
    }

    private func decodeJSON<T: Decodable>(_ type: T.Type, located url: URL) throws -> T {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(T.self, from: data)
    }

    private func makeAnswerFilename(for answerId: Int) -> String {
        return "\(answerId)_content"
    }

    private func makeQuestionFilename(for answerId: Int) -> String {
        return "\(answerId)"
    }
}
