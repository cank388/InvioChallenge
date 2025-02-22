//
//  CityTableViewCellModel.swift
//  universitylisting
//
//  Created by Can Kalender on 21.02.2025.
//

import Foundation

protocol CityTableViewCellDelegate: AnyObject {
    func didTapExpand(for province: String)
    func didTapUniversityExpand(for university: University)
    func didTapFavorite(for university: University)
    func didTapWebsite(_ urlString: String)
    func didTapPhone(_ phoneNumber: String)
}

enum CityTableViewItemType {
    case province(String, isExpanded: Bool, hasUniversities: Bool)
    case university(University, isFavorite: Bool, isExpanded: Bool)
}

struct CityTableViewCellModel {
    let type: CityTableViewItemType
    
    init(type: CityTableViewItemType) {
        self.type = type
    }
}
