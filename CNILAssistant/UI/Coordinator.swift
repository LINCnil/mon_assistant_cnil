
import Foundation
import UIKit

// Base class for all coordinators.
// Each coordinator keeps an array of children coordinators (to avoid children being deallocated)

protocol Coordinator: AnyObject {
    var parentCoordinator: Coordinator? { get set }

    func start()
    func start(coordinator: Coordinator)
    func didFinish(coordinator: Coordinator)
}

extension BaseCoordinator: NameDescribable {}

class BaseCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var parentCoordinator: Coordinator?

    func start() {
        fatalError("Start method must be implemented")
    }

    deinit {
        #if DEBUG
        print("deinit \(typeName)")
        #endif
    }

    final func start(coordinator: Coordinator) {
        childCoordinators.append(coordinator)
        coordinator.parentCoordinator = self
        coordinator.start()
    }

    final func didFinish(coordinator: Coordinator) {
        if let index = childCoordinators.firstIndex(where: { $0 === coordinator }) {
            childCoordinators.remove(at: index)
            coordinator.parentCoordinator = nil
        }
    }
}
