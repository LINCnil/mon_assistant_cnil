import Foundation
import RxSwift
import RxCocoa
import Action

protocol FirstLaunchSpeechOptionsViewModelDelegate: class {
    func didSelectBack(_ vm: FirstLaunchSpeechOptionsViewModel)
    func didSelectNext(_ vm: FirstLaunchSpeechOptionsViewModel)
}

class FirstLaunchSpeechOptionsViewModel {
    let nextButtonTitle: String
    let backButtonTitle: String
    let title = L10n.Localizable.firstLaunchAutospeechTitle
    let text = L10n.Localizable.firstLaunchAutospeechText
    let speechAutostartText = L10n.Localizable.settingsVoiceSpeechAutostart
    let speakFullArticleText = L10n.Localizable.settingsVoiceSpeakFullArticle

    let currentPage: Int
    let numberOfPages: Int

    weak var delegate: FirstLaunchSpeechOptionsViewModelDelegate?
    private(set) var back: CocoaAction!
    private(set) var next: CocoaAction!

    private(set) var isAutospeechOptionOn: BehaviorRelay<Bool>
    private(set) var isFullArticleOptionOn: BehaviorRelay<Bool>

    init(currentPage: Int, numberOfPages: Int) {
        self.currentPage = currentPage
        self.numberOfPages = numberOfPages

        nextButtonTitle = currentPage == numberOfPages - 1
            ? L10n.Localizable.firstLaunchDone.uppercased()
            : L10n.Localizable.firstLaunchNext.uppercased()
        backButtonTitle = currentPage == 0
            ? L10n.Localizable.firstLaunchSkip.uppercased()
            : L10n.Localizable.firstLaunchBack.uppercased()

        isAutospeechOptionOn = BehaviorRelay<Bool>(
            value: ApplicationSettings.shared.isSpeechAutostartEnabled)
        isFullArticleOptionOn = BehaviorRelay<Bool>(
            value: ApplicationSettings.shared.isSpeakFullArticleEnabled)

        self.next = CocoaAction { [unowned self] in
            Observable.create { observer in
                delegate?.didSelectNext(self)
                observer.onCompleted()
                return Disposables.create {}
            }
        }

        self.back = CocoaAction { [unowned self] in
            Observable.create { observer in
                delegate?.didSelectBack(self)
                observer.onCompleted()
                return Disposables.create {}
            }
        }
    }

    func changeAutospeechOption(to value: Bool) {
        if isAutospeechOptionOn.value != value {
            ApplicationSettings.shared.isSpeechAutostartEnabled = value
            isAutospeechOptionOn.accept(value)
        }
    }

    func changeFullArticleOption(to value: Bool) {
        if isFullArticleOptionOn.value != value {
            ApplicationSettings.shared.isSpeakFullArticleEnabled = value
            isFullArticleOptionOn.accept(value)
        }
    }
}
