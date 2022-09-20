
import Foundation
import UIKit

class ConversationCoordinator: BaseCoordinator {
    private let window: UIWindow

    init(window: UIWindow) {
        self.window = window
    }

    private var navigationController: UINavigationController!
    private var conversationController: ConversationViewController!

    override func start() {
        startConversationScreen()
    }

    private func startConversationScreen() {
        let viewModel = ConversationViewModel()
        viewModel.delegate = self
        conversationController = ConversationViewController(viewModel: viewModel)

        let navigationController = UINavigationControllerExt(rootViewController: conversationController)

        self.navigationController = navigationController

        if self.window.rootViewController == nil {
            self.window.rootViewController = navigationController
        } else {
            AppDelegate.current.setRootViewController(navigationController, to: self.window)
        }
    }

    private func showSettings() {
        let settingsCoordinator = SettingsCoordinator(viewController: navigationController)
        settingsCoordinator.delegate = self
        start(coordinator: settingsCoordinator)
    }

    private func showBookmarks() {
        let bookmarksCoordinator = BookmarksCoordinator(viewController: navigationController)
        bookmarksCoordinator.delegate = self
        start(coordinator: bookmarksCoordinator)
    }

    private func showArticlePage(answer: AnswerContent) {
        let articlePageCoordinator = ArticlePageCoordinator(
            navigationController: navigationController,
            answer: answer)
        articlePageCoordinator.delegate = self
        start(coordinator: articlePageCoordinator)
    }
}

extension ConversationCoordinator: SettingsCoordinatorDelegate {
    func didChangeSettings() {
        conversationController.viewModel.notifySettingsChanged()
    }
}

extension ConversationCoordinator: ConversationViewModelDelegate {
    func didSelectAnswer(_ answer: AnswerContent) {
        showArticlePage(answer: answer)
    }

    func didSelectSettings() {
        showSettings()
    }

    func didSelectBookmarks() {
        showBookmarks()
    }

    func didRequestOpenUrl(_ url: URL) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

extension ConversationCoordinator: BookmarksCoordinatorDelegate {
    func didUpdateBookmarks() {
        // TODO
    }
}

extension ConversationCoordinator: ArticlePageCoordinatorDelegate {
    func didChangeBookmarkState(_ marked: Bool) {
        // TODO
    }
}
