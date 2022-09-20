
import Foundation

class NoResultEntryViewModel: ConversationEntryViewModel {
    let title = L10n.Localizable.conversationNothingFound
    let content = L10n.Localizable.conversationRephraseQuestion
    let questionText: String

    init(questionText: String) {
        self.questionText = questionText
    }
}
