//
//  MainCoordinator.swift
//  universitylisting
//
//  Created by Can Kalender on 20.02.2025.
//

import Foundation

class MainCoordinator: Coordinator {
   
    // MARK: - Properties
    var childCoordinators: [Coordinator] = []
    var router: Router
    
    // MARK: - Life Cycle
    init(router: Router) {
        self.router = router
    }
    
    // MARK: - Methods
    func route(animated: Bool, onDismissed: (() -> Void)?) {
        let splashCoordinator = SplashCoordinator(router: router, navigationController: self.router.navigationController)
        routeToChildCoordinator(splashCoordinator, animated: false, onDismissed: onDismissed)
    }
}
