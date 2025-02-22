//
//  FavoritesScreenViewModel.swift
//  universitylisting
//
//  Created by Can Kalender on 22.02.2025.
//

import Foundation

protocol FavoritesViewModelProtocol {
    func listenFavoritesChanges()
    func loadFavorites()
    func updateCellViewModels(with universities: [University])
    func toggleUniversityExpansion(for university: University)
    func toggleFavorite(for university: University)
}

protocol FavoritesScreenViewModelDelegate: AnyObject {
    func favoritesDidUpdate()
}

final class FavoritesScreenViewModel: FavoritesViewModelProtocol {
    private var favoritesManager: FavoritesManaging
    weak var delegate: FavoritesScreenViewModelDelegate?
    
    private var expandedUniversities: Set<String> = []
    var cellViewModels: [CityTableViewCellModel] = []
    
    init(favoritesManager: FavoritesManaging = FavoritesManager.shared) {
        self.favoritesManager = favoritesManager
        listenFavoritesChanges()
    }
    
    func listenFavoritesChanges() {
        self.favoritesManager.onFavoritesChanged = { [weak self] _ in
            self?.loadFavorites()
        }
    }
        
    
    func loadFavorites() {
        let favorites = favoritesManager.getAllFavorites()
        updateCellViewModels(with: favorites)
    }
    
    func updateCellViewModels(with universities: [University]) {
        cellViewModels = universities.map { university in
            let isExpanded = expandedUniversities.contains(university.name ?? "")
            return CityTableViewCellModel(
                type: .university(
                    university,
                    isFavorite: true,
                    isExpanded: isExpanded
                ),
                searchText: nil
            )
        }
        
        delegate?.favoritesDidUpdate()
    }
    
    func toggleUniversityExpansion(for university: University) {
        if expandedUniversities.contains(university.name ?? "") {
            expandedUniversities.remove(university.name ?? "")
        } else {
            expandedUniversities.insert(university.name ?? "")
        }
        loadFavorites()
    }
    
    func toggleFavorite(for university: University) {
        favoritesManager.toggleFavorite(university)
    }
}
