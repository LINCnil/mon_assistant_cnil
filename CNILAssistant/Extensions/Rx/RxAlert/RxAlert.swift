

import Foundation

typealias RxAlertActionCompletion = (() -> Void)?

struct RxAlertAction {
    let title: String
    let action: RxAlertActionCompletion
}

struct RxAlert {
    let title: String?
    let message: String?
    let actions: [RxAlertAction]

    init(title: String?, message: String?, actions: [RxAlertAction]) {
        self.title = title
        self.message = message
        self.actions = actions
    }
}
