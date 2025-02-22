//
//  FavoritesManager.swift
//  universitylisting
//
//  Created by Can Kalender on 22.02.2025.
//

import Foundation

// Storage Protocol
protocol FavoritesStorage {
    func save(_ favorites: [University])
    func load() -> [University]
}

// Favorite managing protocol
protocol FavoritesManaging {
    var onFavoritesChanged: ((_ favorites: [University]) -> Void)? { get set }
    func addToFavorites(_ university: University)
    func removeFromFavorites(_ university: University)
    func isFavorite(_ university: University) -> Bool
    func getAllFavorites() -> [University]
    func toggleFavorite(_ university: University)
}

// UserDefaults implementation, we can implement other storage types like CoreData, Realm by implementing FavoritesStorage protocol
final class UserDefaultsFavoritesStorage: FavoritesStorage {
    private let defaults = UserDefaults.standard
    private let favoritesKey = "favoriteUniversities"
    
    func save(_ favorites: [University]) {
        if let encoded = try? JSONEncoder().encode(favorites) {
            defaults.set(encoded, forKey: favoritesKey)
        }
    }
    
    func load() -> [University] {
        guard let data = defaults.data(forKey: favoritesKey),
              let favorites = try? JSONDecoder().decode([University].self, from: data) else {
            return []
        }
        return favorites
    }
}

final class FavoritesManager: FavoritesManaging {
    static let shared = FavoritesManager(storage: UserDefaultsFavoritesStorage())
    
    private let storage: FavoritesStorage
    private var favorites: [University]
    var onFavoritesChanged: ((_ favorites: [University]) -> Void)?
    
    init(storage: FavoritesStorage) {
        self.storage = storage
        self.favorites = storage.load()
    }
    
    private func saveFavorites() {
        storage.save(favorites)
        onFavoritesChanged?(favorites)
    }
    
    func addToFavorites(_ university: University) {
        if !isFavorite(university) {
            favorites.append(university)
            saveFavorites()
        }
    }
    
    func removeFromFavorites(_ university: University) {
        favorites.removeAll { $0.name == university.name }
        saveFavorites()
    }
    
    func isFavorite(_ university: University) -> Bool {
        return favorites.contains { $0.name == university.name }
    }
    
    func getAllFavorites() -> [University] {
        return favorites
    }
    
    func toggleFavorite(_ university: University) {
        if isFavorite(university) {
            removeFromFavorites(university)
        } else {
            addToFavorites(university)
        }
    }
}
