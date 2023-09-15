//
//  ProductDetailViewModel.swift
//  DevialetTest
//
//  Created by Faustin on 15/09/2023.
//

import Combine
import Foundation
import UIKit

class ProductDetailViewModel: ObservableObject, ProductDetailServiceProtocol {
    
    // MARK: - Properties
    var product: ProductJoined?
    private var service: ProductDetailService!
    
    // Binding properties
    @Published private(set) var music: Music?
    @Published private(set) var battery: Battery?
    @Published private(set) var isCurrentProductOnline: Bool = true
    
    public init(service: ProductDetailService) {
        self.service = service
    }
    
    /*
     Launch websocketSession to listen to '.listenProductDetail(let serial):' endPoint:
     --> APIServiceEndPoints.listenProductDetail(let serial) -> "ws://127.0.0.1:8080/home/\(serial)")
     to get 'ProductDetail' to be decoded as these following cases:
     - 'Music'(title: String, cover: String, artist: String)
     - 'Battery'(percent: Int)
     */
    func fetchData(url: String) async {
        Task {
            try await self.listenForProductDetailEvents(url: url)
        }
    }
    
    // MARK: - ProductDetailsServiceProtocol Method
    
    func listenForProductDetailEvents(url: String) async throws {
        guard let url = URL(string: url) else { return }
        
        self.service.socketConnection = URLSession.shared.webSocketTask(with: url)
        guard let socketConnection = self.service.socketConnection else { return }
        let stream = AbstractWebsocketService(task: socketConnection)
        
        Task {
            do {
                for try await message in stream {
                    if case .string(let text) = message {
                        if let data = text.data(using: .utf8) {
                            let decoded = try? JSONDecoder().decode(ProductDetail.self, from: data)
                            switch decoded {
                            case .playing(let music):
                                DispatchQueue.main.async {
                                    self.music = music
                                }
                            case .battery(let battery):
                                DispatchQueue.main.async {
                                    self.battery = battery
                                }
                            default:
                                print("I was not parsed :(")
                            }
                        }
                    }
                }
            } catch {
                /*
                 stream ended because current Product is not online anymore
                 */
                print("[DEBUG] - 🔴 {stream ended} -> current Product went offline")
                DispatchQueue.main.async {
                    self.isCurrentProductOnline = false
                }
                throw error // FIXME: don't know if we need this here, because its not an 'error', its just that product is not online anymore or serial is wrong or missing...
            }
            
        }
    }
}
