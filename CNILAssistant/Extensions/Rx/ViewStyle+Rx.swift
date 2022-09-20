
import Foundation
import UIKit
import RxSwift

extension Reactive where Base: ViewStylable {
    var style: Binder<ViewStyle<Base>> {
        return Binder(self.base) { view, style -> Void in
            view.applyStyle(style)
        }
    }
}
