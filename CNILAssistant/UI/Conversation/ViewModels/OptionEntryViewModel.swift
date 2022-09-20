
import Foundation
import RxSwift
import RxCocoa
import Action

struct OptionEntryViewModel {
    let title: String
    let select: CocoaAction

    init(title: String, select: CocoaAction) {
        self.title = title
        self.select = select
    }
}
