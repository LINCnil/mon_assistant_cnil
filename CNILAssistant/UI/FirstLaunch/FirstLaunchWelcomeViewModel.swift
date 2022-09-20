
import Foundation
import RxSwift
import RxCocoa
import Action

protocol FirstLaunchWelcomeViewModelDelegate: class {
    func didSelectStart()
    func didSelectSkip()
}

class FirstLaunchWelcomeViewModel {
    let startButtonTitle = L10n.Localizable.firstLaunchStart.uppercased()
    let skipButtonTitle = L10n.Localizable.firstLaunchSkip.uppercased()
    let welcomeTitle = L10n.Localizable.firstLaunchWelcomeTitle
    let welcomeText = L10n.Localizable.firstLaunchWelcomeText

    weak var delegate: FirstLaunchWelcomeViewModelDelegate?
    private(set) var start: CocoaAction!
    private(set) var skip: CocoaAction!

    init() {
        self.start = CocoaAction { [unowned self] in
            Observable.create { observer in
                delegate?.didSelectStart()
                observer.onCompleted()
                return Disposables.create {}
            }
        }

        self.skip = CocoaAction { [unowned self] in
            Observable.create { observer in
                delegate?.didSelectSkip()
                observer.onCompleted()
                return Disposables.create {}
            }
        }
    }
}
