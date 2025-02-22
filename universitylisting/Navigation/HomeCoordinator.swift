//
//  HomeCoordinator.swift
//  universitylisting
//
//  Created by Can Kalender on 20.02.2025.
//

import UIKit

final class HomeCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var router: Router
        
    private let navigationController: UINavigationController
    
    init(router: Router, navigationController: UINavigationController) {
        self.router = router
        self.navigationController = navigationController
    }
    
    func start(universities: [UniversityData]) {
        let storyBoard = UIStoryboard(name: "Home", bundle: nil)
        let homeViewController = storyBoard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController

        let homeViewModel = HomeViewModel()
        homeViewModel.setUniversities(universities)
        homeViewController.coordinator = self
        homeViewController.viewModel = homeViewModel
        
        // Setting home view controller as the root view controller
        navigationController.setViewControllers([homeViewController], animated: true)
    }
    
    func route(animated: Bool, onDismissed: (() -> Void)?) {
        
    }

    func goToFavorites() {
        let favoritesVC = FavoritesScreenViewController()
        navigationController.pushViewController(favoritesVC, animated: true)
    }
}
