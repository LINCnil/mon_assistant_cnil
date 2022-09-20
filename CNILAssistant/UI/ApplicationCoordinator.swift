
import Foundation
import UIKit

class ApplicationCoordinator: BaseCoordinator {

    private let window: UIWindow

    init(window: UIWindow) {
        self.window = window
    }

    // MARK: - Coordinator

    override func start() {
        window.makeKeyAndVisible()
        if ApplicationSettings.shared.isFirstLaunchSetupCompleted {
            showConversation()
        } else {
            showFirstLaunch()
        }
    }

    private func showFirstLaunch() {
        let firstLaunchCoordinator = FirstLaunchCoordinator(window: window)
        firstLaunchCoordinator.delegate = self
        start(coordinator: firstLaunchCoordinator)
    }

    private func showConversation() {
        let coordinator = ConversationCoordinator(window: window)
        start(coordinator: coordinator)
    }
}

extension ApplicationCoordinator: FirstLaunchCoordinatorDelegate {
    func didComplete() {
        ApplicationSettings.shared.isFirstLaunchSetupCompleted = true
        showConversation()
    }
}
