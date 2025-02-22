//
//  SplashCoordinator.swift
//  universitylisting
//
//  Created by Can Kalender on 20.02.2025.
//

import Foundation
import UIKit

protocol SplashCoordinatorDelegate: AnyObject {
    func splashCoordinatorDidFinish(_ coordinator: SplashCoordinator)
}

class SplashCoordinator: Coordinator {
    
    // MARK: - Properties
    var childCoordinators: [Coordinator] = []
    var router: Router
    var navigationController: UINavigationController
    weak var delegate: SplashCoordinatorDelegate?
    
    // MARK: - Life Cycle
    init(router: Router, navigationController: UINavigationController) {
        self.router = router
        self.navigationController = navigationController
    }
    
    // MARK: - Methods
    func route(animated: Bool, onDismissed: (() -> Void)?) {
        let storyboard = UIStoryboard(name: "Splash", bundle: nil)
        let splashVC = storyboard.instantiateViewController(withIdentifier: "SplashViewController") as! SplashViewController
        splashVC.coordinator = self
        splashVC.viewModel = SplashViewModel()
        navigationController.pushViewController(splashVC, animated: animated)
    }
        
    func routeToHomepage(universities: [UniversityData]) {
        let homeCoordinator = HomeCoordinator(router: router, navigationController: self.router.navigationController)
        routeToChildCoordinator(homeCoordinator, animated: false, onDismissed: nil)
        homeCoordinator.start(universities: universities)
    }
}
