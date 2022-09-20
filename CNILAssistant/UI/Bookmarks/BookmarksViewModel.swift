

import Foundation
import RxSwift
import RxCocoa
import Action

protocol BookmarksViewModelDelegate: class {
    func didUpdateBookmarks()
    func didSelectAnswer(_ answer: AnswerContent)
}

class BookmarksViewModel {
    let title = L10n.Localizable.bookmarksTitle
    let items = BehaviorRelay<[ConversationTableSectionModel<AnswerEntryViewModel>]>(
        value: [ConversationTableSectionModel(items: [])])

    weak var delegate: BookmarksViewModelDelegate?

    private let answerRepository: AnswerRepository
    private let bookmarksRepository: BookmarksRepository

    private(set) var clearBookmarks: CocoaAction!

    init() {
        bookmarksRepository = DependencyProvider.shared.bookmarksRepository()
        answerRepository = DependencyProvider.shared.answerRepository()

        self.clearBookmarks = CocoaAction { [unowned self] in
            Observable.create { observer in
                bookmarksRepository.removeAll()
                set([])
                delegate?.didUpdateBookmarks()
                observer.onCompleted()
                return Disposables.create {}
            }
        }

        loadBookmarks()
    }

    func notifyBookmarksChanged() {
        loadBookmarks()
    }

    func selectAnswer(_ answer: AnswerContent) {
        delegate?.didSelectAnswer(answer)
    }

    private func loadBookmarks() {
        let ids = bookmarksRepository.getAll()
        if ids.isEmpty {
            set([])
        } else {
            answerRepository.getAnswers(for: ids.reversed(), completion: { [weak self] res in
                switch res {
                case .success(let answers):
                    self?.handleAnswers(answers)
                case .failure(let error):
                    print("Can not load bookmarks, error: \(error.localizedDescription)")
                }
            })
        }
    }

    private func handleAnswers(_ answers: [AnswerContent]) {
        set(answers.map { createAnswerItem(answer: $0) })
    }

    private func set(_ items: [ItemViewModelHolder<AnswerEntryViewModel>]) {
        var section = self.items.value[0]
        section.set(items)
        self.items.accept([section])
    }

    private func createAnswerItem(answer: AnswerContent) -> ItemViewModelHolder<AnswerEntryViewModel> {
        let viewModelHolder: ItemViewModelHolder<AnswerEntryViewModel> = ItemViewModelHolder { _ in
            AnswerEntryViewModel(answer: answer)
        }
        return viewModelHolder
    }
}
