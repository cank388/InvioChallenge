//
//  HomeViewModel.swift
//  universitylisting
//
//  Created by Can Kalender on 20.02.2025.
//

import Foundation

protocol HomeViewModelProtocol {
    var cellViewModels: [Any] { get }
    var universities: [UniversityData] { get }
    var delegate: HomeViewModelDelegate? { get set }
    func searchUniversities(with text: String)
    func toggleFavorite(for university: University)
    func isUniversityFavorited(_ university: University) -> Bool
    var cities: [String] { get }
    func universities(for city: String) -> [University]
    func isExpanded(_ city: String) -> Bool
    func toggleExpansion(for city: String)
    func loadNextPage()
    var isLoadingMore: Bool { get }
    func toggleUniversityExpansion(for university: University)
    func updateCellViewModels()
    func listenFavoritesChanges()
    var hasExpandedItems: Bool { get }
    func collapseAll()
}

protocol HomeViewModelDelegate: AnyObject {
    func universitiesDidUpdate()
    func searchResultsDidUpdate()
}

final class HomeViewModel: HomeViewModelProtocol {
    var cellViewModels: [Any] = []
    weak var delegate: HomeViewModelDelegate?
    private var allUniversities: [UniversityData] = []
    private(set) var universities: [UniversityData] = []
    private var isSearchActive = false
    
    private var favorites: Set<String> = []
    private var expandedCities: Set<String> = []
    private var expandedUniversities: Set<String> = []
    
    private let universityService: UniversityService
    private var currentPage = 1
    private var isLoading = false
    private var hasMorePages = true
    
    private var currentSearchText: String?
    
    private var favoritesManager: FavoritesManaging
    
    init(universityService: UniversityService = UniversityService(),
         favoritesManager: FavoritesManaging = FavoritesManager.shared) {
        self.universityService = universityService
        self.favoritesManager = favoritesManager
        listenFavoritesChanges()
    }
    
    func listenFavoritesChanges() {
        self.favoritesManager.onFavoritesChanged = { [weak self] _ in
            self?.updateCellViewModels()
        }
    }
    
    var cities: [String] {
        return universities.compactMap { $0.province }.sorted()
    }
    
    var isLoadingMore: Bool {
        return isLoading && hasMorePages && !isSearchActive
    }
    
    func setUniversities(_ universities: [UniversityData]) {
        self.allUniversities = universities
        self.universities = universities
        updateCellViewModels()
        delegate?.universitiesDidUpdate()
    }
    
    func updateCellViewModels() {
        var newCellViewModels: [Any] = []
        
        for universityData in universities {
            let isProvinceExpanded = expandedCities.contains(universityData.province ?? "")
            
            newCellViewModels.append(CityTableViewCellModel(
                    type: .province(universityData.province ?? "",
                    isExpanded: isProvinceExpanded,
                    hasUniversities: (universityData.universities?.isEmpty ?? false)),
                    searchText: nil
            ))
            
            // Expanded cities
            if isProvinceExpanded {
                for university in universityData.universities ?? [] {
                    let isUniversityExpanded = expandedUniversities.contains(university.name ?? "")
                    let isFavorite = favoritesManager.isFavorite(university)
                    
                    newCellViewModels.append(CityTableViewCellModel(
                        type: .university(
                            university,
                            isFavorite: isFavorite,
                            isExpanded: isUniversityExpanded
                        ),
                        searchText: currentSearchText
                    ))
                }
            }
        }
        
        if hasMorePages && !isSearchActive {
            newCellViewModels.append(LoadingCellViewModel())
        }
        
        cellViewModels = newCellViewModels
        delegate?.universitiesDidUpdate()
    }
    
    func searchUniversities(with text: String) {
        let searchText = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        currentSearchText = searchText
        
        guard !searchText.isEmpty else {
            isSearchActive = false
            universities = allUniversities
            expandedCities.removeAll()
            expandedUniversities.removeAll()
            currentSearchText = nil
            updateCellViewModels()
            delegate?.searchResultsDidUpdate()
            return
        }
        
        isSearchActive = true
        universities = allUniversities.compactMap { universityData in
            guard let universities = universityData.universities?.filter({ university in
                let name = university.name?.lowercased() ?? ""
                return name.contains(searchText)
            }), !universities.isEmpty else {
                return nil
            }
            
            // Open searched cities
            expandedCities.insert(universityData.province ?? "")
            
            return UniversityData(
                id: universityData.id,
                province: universityData.province,
                universities: universities
            )
        }
        
        updateCellViewModels()
        delegate?.searchResultsDidUpdate()
    }
    
    func toggleFavorite(for university: University) {
        favoritesManager.toggleFavorite(university)
        updateCellViewModels()
    }
    
    func isUniversityFavorited(_ university: University) -> Bool {
        return favoritesManager.isFavorite(university)
    }
    
    func universities(for city: String) -> [University] {
        return universities
            .first(where: { $0.province == city })?
            .universities ?? []
    }
    
    func isExpanded(_ city: String) -> Bool {
        return expandedCities.contains(city)
    }
    
    func toggleExpansion(for city: String) {
        if expandedCities.contains(city) {
            expandedCities.remove(city)
        } else {
            expandedCities.insert(city)
        }
        // Expansion değiştiğinde cell view model'leri güncellememiz gerekiyor
        updateCellViewModels()
    }
    
    func toggleUniversityExpansion(for university: University) {
        if expandedUniversities.contains(university.name ?? "") {
            expandedUniversities.remove(university.name ?? "")
        } else {
            expandedUniversities.insert(university.name ?? "")
        }
        updateCellViewModels()
    }
    
    func loadNextPage() {
        guard !isLoading && hasMorePages && !isSearchActive else { return }
        
        isLoading = true
        
        universityService.posts(with: currentPage + 1) { [weak self] result in
            guard let self = self else { return }
            
            self.isLoading = false
            
            switch result {
            case .success(let response):
                self.currentPage += 1
                self.hasMorePages = (response.currentPage ?? 0) < (response.totalPage ?? 0)
                
                if let newData = response.data {
                    self.allUniversities.append(contentsOf: newData)
                    self.universities = self.allUniversities
                    self.updateCellViewModels()
                    self.delegate?.universitiesDidUpdate()
                }
                
            case .failure(let error):
                print("Error loading next page: \(error)")
            }
        }
    }
    
    var hasExpandedItems: Bool {
        // Check if there is any university on expanded cities
        let hasExpandedCityWithUniversities = expandedCities.contains { city in
            universities.first { data in
                data.province == city && !(data.universities?.isEmpty ?? true)
            } != nil
        }
        
        return hasExpandedCityWithUniversities || !expandedUniversities.isEmpty
    }
    
    func collapseAll() {
        expandedCities.removeAll()
        expandedUniversities.removeAll()
        updateCellViewModels()
    }
}
