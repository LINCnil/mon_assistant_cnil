
import Foundation
import UIKit

class BaseViewController<TViewModel>: UIViewControllerExt {
    let viewModel: TViewModel

    init(viewModel: TViewModel) {
        self.viewModel = viewModel
        super.init()
    }

    override func viewDidLoad() {
        super .viewDidLoad()
        setupBindings()
    }

    open func setupBindings() {
        fatalError("setupBindings method must be implemented")
    }
}
