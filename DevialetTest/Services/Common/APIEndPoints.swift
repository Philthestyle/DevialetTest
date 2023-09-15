//
//  APIEndPoints.swift
//  DevialetTest
//
//  Created by Faustin on 15/09/2023.
//

import Foundation

/*
 Listing API endPoints provided by your documentation
 */
enum APIServiceEndPoints {
    case serverBaseURL
    case listenProductEvents
    case listenProductDetail(serial: String)
    
    // Url string representation
    var urlString : String {
        switch self {
        case .serverBaseURL:
            return "ws://127.0.0.1:8080"
        case .listenProductEvents:
            return "ws://127.0.0.1:8080/home"
        case .listenProductDetail(let serial):
            return "ws://127.0.0.1:8080/home/\(serial)"
        }
    }
}
