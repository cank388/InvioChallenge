//
//  SplashViewController.swift
//  universitylisting
//
//  Created by Can Kalender on 20.02.2025.
//

import UIKit

final class SplashViewController: UIViewController {
    
    private var viewModel: SplashViewModelProtocol
        
    init(viewModel: SplashViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    func splashLoadingCompleted() {
        // TODO: Ana sayfa
        
    }
    
    func splashLoadingFailed(with error: Error) {
        showError(error)
    }
}
