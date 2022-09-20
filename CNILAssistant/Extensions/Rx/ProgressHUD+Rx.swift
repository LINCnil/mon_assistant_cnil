

import UIKit
import ProgressHUD
import RxSwift
import RxCocoa

class ProgressHUDRxWrapper {
    fileprivate var status: String?

    init() {
    }

    fileprivate func show() {
        if let status = status {
            ProgressHUD.show(
                status,
                interaction: false)
        } else {
            ProgressHUD.show(
                interaction: false)
        }
    }

    fileprivate func dismiss() {
        ProgressHUD.dismiss()
    }
}

extension ProgressHUDRxWrapper: ReactiveCompatible {}

extension Reactive where Base: ProgressHUDRxWrapper {
    var status: Binder<String> {
        return Binder(self.base) { hudWrapper, status in
            hudWrapper.status = status
        }
    }

    var isAnimating: Binder<Bool> {
        return Binder(self.base) { hudWrapper, show in
            if show {
                hudWrapper.show()
            } else {
                hudWrapper.dismiss()
            }
        }
    }
}
