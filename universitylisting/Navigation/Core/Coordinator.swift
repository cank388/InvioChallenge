//
//  Coordinator.swift
//  universitylisting
//
//  Created by Can Kalender on 20.02.2025.
//

import UIKit

public protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    var router: Router { get }

    func route(animated: Bool, onDismissed: (() -> Void)?)
    func unroute(animated: Bool)
    func routeToChildCoordinator(_ coordinator: Coordinator, animated: Bool, onDismissed: (() -> Void)?)
}

public extension Coordinator {
    
    func unroute(animated: Bool) {
        router.unroute(animated: animated)
    }
    
    func routeToChildCoordinator(_ coordinator: Coordinator, animated: Bool, onDismissed: (() -> Void)?) {
        childCoordinators.append(coordinator)
        coordinator.route(animated: animated) { [weak self, weak coordinator] in
            guard let `self` = self, let coordinator = coordinator else { return }
            self.removeChildCoordinator(coordinator)
            onDismissed?()
        }
    }
    
    private func removeChildCoordinator(_ coordinator: Coordinator) {
        guard let index = childCoordinators.firstIndex(where: { $0 === coordinator }) else { return }
        childCoordinators.remove(at: index)
    }
    
}

