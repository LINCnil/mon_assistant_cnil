
import Foundation
import RxSwift
import RxCocoa
import Action

protocol ArticlePageViewModelDelegate: class {
    func didChangeBookmarkState(_ marked: Bool)
}

class ArticlePageViewModel {
    let title = L10n.Localizable.articlePageTitle
    weak var delegate: ArticlePageViewModelDelegate?

    let answer: AnswerContent
    let questionText: String
    let answerHtmlBody: String

    let returnToSearchCaption = L10n.Localizable.articlePageReturnToSearch

    let isSpeaking: BehaviorRelay<Bool>
    private(set) var toggleSpeaking: CocoaAction!

    let isBookmarked: BehaviorRelay<Bool>
    private(set) var toggleBookmark: CocoaAction!

    private let bookmarksRepository: BookmarksRepository
    private var speechSynthesizer: SpeechSynthesizer

    init(answer: AnswerContent) {
        self.bookmarksRepository = DependencyProvider.shared.bookmarksRepository()
        self.answerHtmlBody = answer.htmlBody
        self.answer = answer
        self.questionText = answer.question

        self.speechSynthesizer = AVSpeechSynthesizerImplementation()
        self.isBookmarked = BehaviorRelay<Bool>(value: bookmarksRepository.contains(answerId: answer.id))

        if ApplicationSettings.shared.isSpeechAutostartEnabled {
            self.isSpeaking = BehaviorRelay<Bool>(value: true)
            speak(forceFromStart: true)
        } else {
            self.isSpeaking = BehaviorRelay<Bool>(value: false)
        }

        self.speechSynthesizer.onSpeakCompleted = { [weak self] in
            self?.isSpeaking.accept(false)
        }

        self.toggleSpeaking = CocoaAction { [unowned self] in
            Observable.create { observer in
                if isSpeaking.value {
                    speechSynthesizer.pauseSpeaking()
                } else {
                    speak()
                }
                isSpeaking.accept(!isSpeaking.value)
                observer.onCompleted()
                return Disposables.create {}
            }
        }

        self.toggleBookmark = CocoaAction { [unowned self] in
            return Observable.create { observer in
                if isBookmarked.value {
                    bookmarksRepository.remove(answerId: answer.id)
                } else {
                    bookmarksRepository.add(answerId: answer.id)
                }
                isBookmarked.accept(!isBookmarked.value)
                delegate?.didChangeBookmarkState(isBookmarked.value)
                observer.onCompleted()
                return Disposables.create {}
            }
        }
    }

    private func speak(forceFromStart: Bool = false) {
        if !forceFromStart && speechSynthesizer.isPaused {
            speechSynthesizer.continueSpeaking()
        } else {
            if ApplicationSettings.shared.isSpeakFullArticleEnabled {
                speechSynthesizer.speak(answerHtmlBody.htmlAttributed())
            } else {
                let firstSentence = answerHtmlBody.htmlAttributed().string.firstSentence()
                speechSynthesizer.speak(firstSentence)
            }
        }
    }

    func stopPlaying() {
        speechSynthesizer.stopSpeaking()
        isSpeaking.accept(false)
    }
}
