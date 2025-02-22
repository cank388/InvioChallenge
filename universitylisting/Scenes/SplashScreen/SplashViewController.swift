//
//  SplashViewController.swift
//  universitylisting
//
//  Created by Can Kalender on 20.02.2025.
//

import UIKit

final class SplashViewController: UIViewController {
    
    var viewModel: SplashViewModelProtocol
    weak var coordinator: SplashCoordinator?
        
    init(_ viewModel: SplashViewModel = .init()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = SplashViewModel()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        viewModel.fetchUniversities()
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(
            title: "Try Again",
            style: .default,
            handler: nil
        ))
        
        present(alert, animated: true)
    }
}

// MARK: - SplashViewModelDelegate
extension SplashViewController: SplashViewModelDelegate {
    func splashLoadingCompleted(universities: [UniversityData]) {
        let homeViewModel = HomeViewModel()
        homeViewModel.setUniversities(universities)
        let storyBoard = UIStoryboard(name: "Home", bundle: nil)
        let homeViewController = storyBoard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        homeViewController.viewModel = homeViewModel
        navigationController?.pushViewController(homeViewController, animated: true)
//        if let navigationController = navigationController {
//            navigationController.pushViewController(homeViewController, animated: true)
//        }
//        let newNavigationController = UINavigationController(rootViewController: homeViewController)
//        newNavigationController.pushViewController(newNavigationController, animated: true)
        
        //let hostingController = UIHostingController(rootView: homeView)
        
//        // Eğer zaten bir navigation controller içindeysek
//        if let navigationController = navigationController {
//            navigationController.pushViewController(hostingController, animated: true)
//        } else {
//            // Eğer navigation controller yoksa yeni bir tane oluştur
//            let newNavigationController = UINavigationController(rootViewController: hostingController)
//            newNavigationController.modalPresentationStyle = .fullScreen
//            present(newNavigationController, animated: true)
//        }
    }
    
    func splashLoadingFailed(with error: Error) {
        showError(error)
    }
}
