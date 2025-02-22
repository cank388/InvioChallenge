//
//  Localizable+Extension.swift
//  universitylisting
//
//  Created by Can Kalender on 22.02.2025.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}