//
//  UniversityService.swift
//  universitylisting
//
//  Created by Can Kalender on 20.02.2025.
//

import Foundation

class UniversityService {
    
    // MARK: - Types
    typealias ResultCompletion<T> = (Result<T, Error>) -> Void
    
    // MARK: Properties
    private let networkManager: NetworkManager
    
    // MARK: - Life Cycle
    init(_ networkManager: NetworkManager = .init()) {
        self.networkManager = networkManager
    }
    
    // MARK: - Methods
    func posts(with pageId: Int, _ completion: @escaping ResultCompletion<UniversityResponse>) {
        networkManager.responseDecodable(
            of: UniversityResponse.self,
            endpoint: UniversityEndpoint.universities(pageId: pageId),
            completion: completion
        )
    }
}
