//
//  ProductDetailService.swift
//  DevialetTest
//
//  Created by Faustin on 15/09/2023.
//

import Foundation

protocol ProductDetailServiceProtocol {
    func listenForProductDetailEvents(url: String) async throws
}

struct ProductDetailService {
    static let shared = ProductDetailService()
    var baseUrl: String = APIServiceEndPoints.listenProductEvents.urlString
    var socketConnection: URLSessionWebSocketTask?
}
