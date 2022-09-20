
import Foundation
import UIKit

class UINavigationControllerExt: UINavigationController {
    var isStarted: Bool = false
    var isAppeared: Bool = false

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("Unavailable")
    }

    deinit {
        #if DEBUG
        print("deinit \(typeName)")
        #endif
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if isStarted && isBeingDismissed {
            viewDidFinish(animated)
        }
        isAppeared = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isStarted && isBeingPresented {
            viewWillStart(animated)
        }
        isAppeared = true
    }

    final func viewDidFinish(_ animated: Bool) {
        children.reversed().map { $0 as? UIViewControllerExt }.forEach { $0?.viewDidFinish(animated) }
        isStarted = false
    }

    final func viewWillStart(_ animated: Bool) {
        children.reversed().map { $0 as? UIViewControllerExt }.forEach { $0?.viewWillStart(animated) }
        isStarted = true
    }
}
