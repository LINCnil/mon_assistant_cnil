import Foundation
import RxSwift
import RxCocoa
import Action

protocol FirstLaunchSelectVoiceViewModelDelegate: class {
    func didSelectBack(_ vm: FirstLaunchSelectVoiceViewModel)
    func didSelectNext(_ vm: FirstLaunchSelectVoiceViewModel)
}

class FirstLaunchSelectVoiceViewModel {
    let nextButtonTitle: String
    let backButtonTitle: String
    let title = L10n.Localizable.firstLaunchAssistantVoiceTitle
    let text = L10n.Localizable.firstLaunchAssistantVoiceText
    let maleButtonTitle = L10n.Localizable.settingsVoiceOptionMale
    let femaleButtonTitle = L10n.Localizable.settingsVoiceOptionFemale

    let currentPage: Int
    let numberOfPages: Int

    weak var delegate: FirstLaunchSelectVoiceViewModelDelegate?
    private(set) var back: CocoaAction!
    private(set) var next: CocoaAction!

    private(set) var selected: BehaviorRelay<SpeechSynthesizerVoiceGender>

    init(currentPage: Int, numberOfPages: Int) {
        self.currentPage = currentPage
        self.numberOfPages = numberOfPages

        nextButtonTitle = currentPage == numberOfPages - 1
            ? L10n.Localizable.firstLaunchDone.uppercased()
            : L10n.Localizable.firstLaunchNext.uppercased()
        backButtonTitle = currentPage == 0
            ? L10n.Localizable.firstLaunchSkip.uppercased()
            : L10n.Localizable.firstLaunchBack.uppercased()

        self.selected = BehaviorRelay<SpeechSynthesizerVoiceGender>(
            value: ApplicationSettings.shared.speechVoiceGender)

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

    func select(voice: SpeechSynthesizerVoiceGender) {
        if selected.value != voice {
            ApplicationSettings.shared.speechVoiceGender = voice
            selected.accept(voice)
        }
    }
}
