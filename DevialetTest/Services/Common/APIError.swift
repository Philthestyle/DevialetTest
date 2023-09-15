//
//  APIError.swift
//  DevialetTest
//
//  Created by Faustin on 15/09/2023.
//

import Foundation

/*
 To handle API error into websocket fetching data methods
 */
enum ApiError: Error {
    case badUrl
    case badResponse
    case parseError
    case wrongFormat
}
