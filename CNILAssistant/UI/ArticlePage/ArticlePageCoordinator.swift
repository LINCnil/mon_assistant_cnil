

import Foundation
import UIKit

protocol ArticlePageCoordinatorDelegate: class {
    func didChangeBookmarkState(_ marked: Bool)
}

class ArticlePageCoordinator: BaseCoordinator {
    private let navigationController: UINavigationController
    private let answer: AnswerContent

    weak var delegate: ArticlePageCoordinatorDelegate?

    init(navigationController: UINavigationController, answer: AnswerContent) {
        self.navigationController = navigationController
        self.answer = answer
    }

    override func start() {
        let viewModel = ArticlePageViewModel(answer: answer)
        viewModel.delegate = self
        let articlePageViewController = ArticlePageViewController(viewModel: viewModel)
        articlePageViewController.presentationDelegate = self

        navigationController.pushViewController(articlePageViewController, animated: true)
    }

    // MARK: - Private

    private func showPipelineLogs() {
        start(coordinator: PipelineLogsCoordinator(navigationController: navigationController))
    }
}

extension ArticlePageCoordinator: ArticlePageViewModelDelegate {
    func didChangeBookmarkState(_ marked: Bool) {
        delegate?.didChangeBookmarkState(marked)
    }
}

extension ArticlePageCoordinator: ViewControllerPresentationDelegate {
    func viewControllerWillStart(_ viewController: UIViewController) {
    }

    func viewControllerDidFinish(_ viewController: UIViewController) {
        parentCoordinator?.didFinish(coordinator: self)
    }
}
