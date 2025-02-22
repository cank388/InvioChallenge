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
    private var rootViewController: SplashViewController!
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
    
    func finishSplash() {
        delegate?.splashCoordinatorDidFinish(self)
    }
    
//    // Splash ekranından üniversite listesine geçiş için yeni metod
//    func routeToUniversityList() {
//        let universityListViewController = UniversityListViewController()
//        router.route(to: universityListViewController, animated: true, onDismissed: nil)
//    }
}
