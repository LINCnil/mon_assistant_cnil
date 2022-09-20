
import Foundation
import UIKit

protocol ViewControllerPresentationDelegate: class {
    func viewControllerWillStart(_ viewController: UIViewController)
    func viewControllerDidFinish(_ viewController: UIViewController)
}

class UIViewControllerExt: UIViewController {
    var isAppeared: Bool = false
    var isStarted: Bool = false
    weak var presentationDelegate: ViewControllerPresentationDelegate?

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("Unavailable")
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    deinit {
        #if DEBUG
        print("deinit \(typeName)")
        #endif
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if isStarted && (isBeingDismissed || isMovingFromParent) {
            viewDidFinish(animated)
        }
        isAppeared = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isStarted && (isBeingPresented || isMovingToParent) {
            viewWillStart(animated)
        }
        isAppeared = true
    }

    open func viewDidFinish(_ animated: Bool) {
        presentationDelegate?.viewControllerDidFinish(self)
        isStarted = false
    }

    open func viewWillStart(_ animated: Bool) {
        presentationDelegate?.viewControllerWillStart(self)
        isStarted = true
    }
}
