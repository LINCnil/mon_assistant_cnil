import Foundation
import RxSwift
import RxCocoa
import Action

class WelcomeEntryViewModel: ConversationEntryViewModel {
    let title = L10n.Localizable.conversationWelcomeTitle
    let content = L10n.Localizable.conversationWelcomeContent

    let suggestionsQuestions: [OptionEntryViewModel]

    private let suggestions: [AnswerContent]

    init(suggestions: [AnswerContent],
         onSuggestionSelected: @escaping (AnswerContent) -> Void,
         onBookmarksSelected: @escaping () -> Void,
         onNewsSelected: @escaping () -> Void) {
        self.suggestions = suggestions

        var options: [OptionEntryViewModel] = suggestions.enumerated().map { index, element in
            let selectAction = CocoaAction(workFactory: { _ in
                Observable<Void>.throttle(
                    Observable.just(onSuggestionSelected(suggestions[index])),
                    dueTime: RxTimeInterval.seconds(1),
                    scheduler: MainScheduler.instance)
            })
            return OptionEntryViewModel(title: element.question, select: selectAction)
        }

        let viewBookmarksAction = CocoaAction(workFactory: { _ in
            Observable<Void>.throttle(
                Observable.just(onBookmarksSelected()),
                dueTime: RxTimeInterval.seconds(1),
                scheduler: MainScheduler.instance)
        })
        options.append(OptionEntryViewModel(title: L10n.Localizable.conversationWelcomeViewBookmarksOption, select: viewBookmarksAction))

        let viewNewsAction = CocoaAction(workFactory: { _ in
            Observable<Void>.throttle(
                Observable.just(onNewsSelected()),
                dueTime: RxTimeInterval.seconds(1),
                scheduler: MainScheduler.instance)
        })
        options.append(OptionEntryViewModel(title: L10n.Localizable.conversationWelcomeNewsOption, select: viewNewsAction))

        self.suggestionsQuestions = options
    }
}
