

import Foundation

struct AnswerMapper {
    func map(answerDto: AnswerDto, questionDto: QuestionDto) throws -> AnswerContent {
        guard let id = Int(answerDto.id) else { throw AnswerRepositoryError.invalidFormat(name: answerDto.id, inner: nil) }
        let metadata = questionDto.metadata.first
        let keywords = metadata?.content.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }

        return AnswerContent(
            id: id,
            htmlBody: try answerDto.contents.first(or: { AnswerRepositoryError.invalidFormat(name: answerDto.id, inner: nil) }).content,
            question: try questionDto.names.first(or: { AnswerRepositoryError.invalidFormat(name: questionDto.id, inner: nil) }).name,
            keywords: keywords ?? [])
    }
}
