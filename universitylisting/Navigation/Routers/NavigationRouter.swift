//
//  NavigationRouter.swift
//  universitylisting
//
//  Created by Can Kalender on 20.02.2025.
//

import UIKit

public class NavigationRouter: NSObject, Router {
    
    // MARK: - Properties
    public var navigationController: UINavigationController
    private let routerRootController: UIViewController?
    private var onDismissForViewController: [UIViewController: (() -> Void)] = [:]
    
    // MARK: - Lifecycle
    public init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.routerRootController = navigationController.viewControllers.first
        super.init()
        self.navigationController.delegate = self
    }
    
    // MARK: - Router Protocol
    public func route(to viewController: UIViewController, animated: Bool, onDismissed: (() -> Void)?) {
        onDismissForViewController[viewController] = onDismissed
        navigationController.pushViewController(viewController, animated: animated)
    }
    
    public func unroute(animated: Bool) {
        guard let routerRootController = routerRootController else {
            navigationController.popToRootViewController(animated: animated)
            return
        }
        
        performOnDismissed(for: routerRootController)
        navigationController.popToViewController(routerRootController, animated: animated)
    }
    
    // MARK: - Methods
    
    private func performOnDismissed(for viewController: UIViewController) {
        guard let onDismiss = onDismissForViewController[viewController] else { return }
        
        onDismiss()
        onDismissForViewController[viewController] = nil
    }
}

extension NavigationRouter: UINavigationControllerDelegate {
    
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let dismissedViewController = navigationController.transitionCoordinator?.viewController(forKey: .from),
              navigationController.viewControllers.contains(dismissedViewController) == false else {
            return
        }
        
        performOnDismissed(for: dismissedViewController)
    }
    
}
