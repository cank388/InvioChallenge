//
//  SplashViewModel.swift
//  universitylisting
//
//  Created by Can Kalender on 20.02.2025.
//

import Foundation

protocol SplashViewModelDelegate: AnyObject {
    func splashLoadingCompleted(universities: [UniversityData])
    func splashLoadingFailed(with error: Error)
}

protocol SplashViewModelProtocol {
    var delegate: SplashViewModelDelegate? { get set }
    func fetchUniversities()
}

final class SplashViewModel: SplashViewModelProtocol {
    private var service: UniversityService
    weak var delegate: SplashViewModelDelegate?
    
    init(_ service: UniversityService = .init()) {
        self.service = service
    }
    
    func fetchUniversities() {
        service.posts(with: 1) { [weak self] result in
            switch result {
            case .success(let response):
                if let universities = response.data {
                    self?.delegate?.splashLoadingCompleted(universities: universities)
                }
            case .failure(let error):
                self?.delegate?.splashLoadingFailed(with: error)
            }
        }
    }
}

