//
//  ProductListService.swift
//  DevialetTest
//
//  Created by Faustin on 15/09/2023.
//

import Foundation

protocol ProductListServiceProtocol {
    func listenForProductEvents(url: String) async throws
}

class ProductListService {
    static let shared = ProductListService()
    var url: String = APIServiceEndPoints.listenProductEvents.urlString
    var socketConnection: URLSessionWebSocketTask?
    
    init() {
        socketConnection = URLSession.shared.webSocketTask(with: URL(string: url)!)
    }
}
