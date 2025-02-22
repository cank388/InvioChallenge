//
//  University.swift
//  universitylisting
//
//  Created by Can Kalender on 20.02.2025.
//

import Foundation

struct UniversityResponse: Codable {
    let currentPage, totalPage, total, itemPerPage: Int?
    let pageSize: Int?
    let data: [UniversityData]?
}

// MARK: - Datum
struct UniversityData: Codable {
    let id: Int?
    let province: String?
    let universities: [University]?
}

// MARK: - University
struct University: Codable {
    let name, phone, fax: String?
    let website: String?
    let email, adress, rector: String?
}

extension University: Equatable {
    static func == (lhs: University, rhs: University) -> Bool {
        return lhs.website == rhs.website
    }
}
