import Foundation
import RxSwift
import RxCocoa
import Action

class AnswerEntryViewModel: ConversationEntryViewModel {
    let answer: AnswerContent
    let questionText: String
    let answerHtmlBody: String

    init(answer: AnswerContent) {
        self.answerHtmlBody = answer.htmlBody
        self.answer = answer
        self.questionText = answer.question
    }
}
