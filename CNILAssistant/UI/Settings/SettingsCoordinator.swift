import Foundation
import UIKit

protocol SettingsCoordinatorDelegate: class {
    func didChangeSettings()
}

class SettingsCoordinator: BaseCoordinator {
    private let viewController: UIViewController
    private var navigationController: UINavigationController!

    weak var delegate: SettingsCoordinatorDelegate?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    override func start() {
        let viewModel = SettingsViewModel()
        viewModel.delegate = self
        let settingsViewController = SettingsViewController(viewModel: viewModel)
        settingsViewController.presentationDelegate = self

        let closeButton = UIBarButtonItem(
            image: UIImage(systemSymbol: .xmark),
            style: .plain,
            target: self,
            action: #selector(onViewControllerCloseButtonClicked)
        )

        settingsViewController.navigationItem.leftBarButtonItem = closeButton

        navigationController = UINavigationControllerExt(rootViewController: settingsViewController)
//        navigationController.modalPresentationStyle = .fullScreen

        viewController.present(navigationController, animated: true, completion: nil)
    }

    // MARK: - Private

    private func showPipelineLogs() {
        start(coordinator: PipelineLogsCoordinator(navigationController: navigationController))
    }

    @objc private func onViewControllerCloseButtonClicked() {
        viewController.dismiss(animated: true)
    }
}

extension SettingsCoordinator: SettingsViewModelDelegate {
    func didRequestSelectionOf(setting: String, options: [String], selected: Int?, completion: @escaping (Int?) -> Void) {
        let selectionController = SelectSettingOptionViewController()
        selectionController.settingTitle = setting
        selectionController.settingOptions = options
        selectionController.selectedSettingOption = selected
        selectionController.onSelected = completion
        navigationController.pushViewController(selectionController, animated: true)
    }

    func didSelectLogs() {
        showPipelineLogs()
    }

    func didChangeSettings() {
        delegate?.didChangeSettings()
    }
}

extension SettingsCoordinator: ViewControllerPresentationDelegate {
    func viewControllerWillStart(_ viewController: UIViewController) {
    }

    func viewControllerDidFinish(_ viewController: UIViewController) {
        parentCoordinator?.didFinish(coordinator: self)
    }
}
