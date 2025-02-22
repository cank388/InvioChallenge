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
            title: "Done",
            style: .default,
            handler: nil
        ))
        
        present(alert, animated: true)
    }
}

// MARK: - SplashViewModelDelegate
extension SplashViewController: SplashViewModelDelegate {
    func splashLoadingCompleted(universities: [UniversityData]) {
        coordinator?.routeToHomepage(universities: universities)
    }
    
    func splashLoadingFailed(with error: Error) {
        showError(error)
    }
}
