

import Foundation
import UIKit

protocol RxAlertViewable {
    func showAlert(_ alert: RxAlert)
}

extension RxAlertViewable where Self: UIViewController {
    func showAlert(_ alert: RxAlert) {
        let alertController = UIAlertController(title: alert.title, message: alert.message, preferredStyle: .alert)
        let actions = alert.actions.map { actionInfo in
            UIAlertAction(title: actionInfo.title, style: .default) { _ in
                actionInfo.action?()
            }
        }
        for action in actions {
            alertController.addAction(action)
        }
        present(alertController, animated: true, completion: nil)
    }
}
