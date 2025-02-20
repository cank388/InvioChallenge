//
//  UniversityEndpoint.swift
//  universitylisting
//
//  Created by Can Kalender on 20.02.2025.
//

import Foundation
import Alamofire

enum UniversityEndpoint: APIEndpoint {
    case universities(pageId: Int)
   
    var method: Alamofire.HTTPMethod {
        switch self {
        case .universities: return .get
        }
    }
    
    var path: String {
        switch self {
        case .universities(let pageId): return "universities-at-turkey/page-\(pageId).json"
        }
    }
    
    var type: EndpointType {
        switch self {
        case .universities:
            return .regular(
                parameters: nil, encoding: URLEncoding.default
            )
        }
    }
       
}
