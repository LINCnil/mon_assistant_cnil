import Foundation
import UIKit

protocol FirstLaunchCoordinatorDelegate: class {
    func didComplete()
}

class FirstLaunchCoordinator: BaseCoordinator {
    private var navigationController: UINavigationController!
    weak var delegate: FirstLaunchCoordinatorDelegate?
    private let window: UIWindow

    init(window: UIWindow) {
        self.window = window
    }

    override func start() {
        let viewModel = FirstLaunchWelcomeViewModel()
        viewModel.delegate = self
        let firstLaunchWelcomeViewController = FirstLaunchWelcomeViewController(viewModel: viewModel)

        let navigationController = UINavigationControllerExt(rootViewController: firstLaunchWelcomeViewController)
        navigationController.isNavigationBarHidden = true
        navigationController.modalPresentationStyle = .fullScreen
        self.navigationController = navigationController

        if self.window.rootViewController == nil {
            self.window.rootViewController = navigationController
        } else {
            AppDelegate.current.setRootViewController(navigationController, to: self.window)
        }
    }

    // MARK: - Private

    private func showSelectVoice() {
        let viewModel = FirstLaunchSelectVoiceViewModel(currentPage: 0, numberOfPages: 2)
        viewModel.delegate = self
        let selectVoiceViewController = FirstLaunchSelectVoiceViewController(viewModel: viewModel)

        navigationController.pushViewController(selectVoiceViewController, animated: true)
    }

    private func showSpeechOptions() {
        let viewModel = FirstLaunchSpeechOptionsViewModel(currentPage: 1, numberOfPages: 2)
        viewModel.delegate = self
        let speechOptionsViewController = FirstLaunchSpeechOptionsViewController(viewModel: viewModel)

        navigationController.pushViewController(speechOptionsViewController, animated: true)
    }
}

extension FirstLaunchCoordinator: FirstLaunchWelcomeViewModelDelegate {
    func didSelectStart() {
        showSelectVoice()
    }

    func didSelectSkip() {
        parentCoordinator?.didFinish(coordinator: self)
        delegate?.didComplete()
    }
}

extension FirstLaunchCoordinator: FirstLaunchSelectVoiceViewModelDelegate {
    func didSelectBack(_ vm: FirstLaunchSelectVoiceViewModel) {
        parentCoordinator?.didFinish(coordinator: self)
        delegate?.didComplete()
    }

    func didSelectNext(_ vm: FirstLaunchSelectVoiceViewModel) {
        showSpeechOptions()
    }
}

extension FirstLaunchCoordinator: FirstLaunchSpeechOptionsViewModelDelegate {
    func didSelectBack(_ vm: FirstLaunchSpeechOptionsViewModel) {
        navigationController.popViewController(animated: true)
    }

    func didSelectNext(_ vm: FirstLaunchSpeechOptionsViewModel) {
        parentCoordinator?.didFinish(coordinator: self)
        delegate?.didComplete()
    }
}
