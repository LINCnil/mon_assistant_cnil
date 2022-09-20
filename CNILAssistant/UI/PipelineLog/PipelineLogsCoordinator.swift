import Foundation
import UIKit

class PipelineLogsCoordinator: BaseCoordinator {
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start() {
        let logController = PipelineLogsViewController(viewModel: PipelineLogsViewModel())
        logController.presentationDelegate = self

        navigationController.pushViewController(logController, animated: true)
    }
}

extension PipelineLogsCoordinator: ViewControllerPresentationDelegate {
    func viewControllerWillStart(_ viewController: UIViewController) {
    }

    func viewControllerDidFinish(_ viewController: UIViewController) {
        parentCoordinator?.didFinish(coordinator: self)
    }
}
