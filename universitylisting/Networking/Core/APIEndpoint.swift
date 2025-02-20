//
//  APIEndpoint.swift
//  universitylisting
//
//  Created by Can Kalender on 20.02.2025.
//

import Alamofire

enum EndpointType {
    case regular(parameters: [String: Any]?, encoding: ParameterEncoding)
}

protocol APIEndpoint {
    var method: HTTPMethod { get }
    var path: String { get }
    var type: EndpointType { get }
}

