

import Foundation
import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIViewController, Base: RxAlertViewable {
    var alert: Binder<RxAlert> {
        Binder(base) { viewController, alert in
            viewController.showAlert(alert)
        }
    }
}
