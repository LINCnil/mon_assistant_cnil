
import Foundation
import UIKit

protocol BookmarksCoordinatorDelegate: class {
    func didUpdateBookmarks()
}

class BookmarksCoordinator: BaseCoordinator {
    private let viewController: UIViewController
    private var navigationController: UINavigationController!
    private var bookmarksViewController: BookmarksViewController!

    weak var delegate: BookmarksCoordinatorDelegate?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    override func start() {
        let viewModel = BookmarksViewModel()
        viewModel.delegate = self
        bookmarksViewController = BookmarksViewController(viewModel: viewModel)
        bookmarksViewController.presentationDelegate = self

        let closeButton = UIBarButtonItem(
            image: UIImage(systemSymbol: .xmark),
            style: .plain,
            target: self,
            action: #selector(onViewControllerCloseButtonClicked)
        )

        bookmarksViewController.navigationItem.leftBarButtonItem = closeButton

        navigationController = UINavigationControllerExt(rootViewController: bookmarksViewController)
        viewController.present(navigationController, animated: true, completion: nil)
    }

    // MARK: - Private

    private func showArticlePage(answer: AnswerContent) {
        let articlePageCoordinator = ArticlePageCoordinator(navigationController: navigationController, answer: answer)
        articlePageCoordinator.delegate = self
        start(coordinator: articlePageCoordinator)
    }

    @objc private func onViewControllerCloseButtonClicked() {
        viewController.dismiss(animated: true)
    }
}

extension BookmarksCoordinator: ArticlePageCoordinatorDelegate {
    func didChangeBookmarkState(_ marked: Bool) {
        bookmarksViewController.viewModel.notifyBookmarksChanged()
        delegate?.didUpdateBookmarks()
    }
}

extension BookmarksCoordinator: BookmarksViewModelDelegate {
    func didSelectAnswer(_ answer: AnswerContent) {
        showArticlePage(answer: answer)
    }

    func didUpdateBookmarks() {
        delegate?.didUpdateBookmarks()
    }
}

extension BookmarksCoordinator: ViewControllerPresentationDelegate {
    func viewControllerWillStart(_ viewController: UIViewController) {
    }

    func viewControllerDidFinish(_ viewController: UIViewController) {
        parentCoordinator?.didFinish(coordinator: self)
    }
}
