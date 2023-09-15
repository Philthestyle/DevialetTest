//
//  ProductListViewModel.swift
//  DevialetTest
//
//  Created by Faustin on 15/09/2023.
//

import Foundation
import Combine

class ProductListViewModel: ObservableObject, ProductListServiceProtocol {
    
    // MARK: - Properties
    let service: ProductListService!
    
    @Published private(set) var productCellViewModels: [ProductListCellViewModel] = []
    
    // MARK: - Init service & fetchData
    
    public init(service: ProductListService) {
        self.service = service
        /*
         Launch websocketSession to listen to 'productList' endPoint:
            --> APIServiceEndPoints.listenProductEvents -> "ws://127.0.0.1:8080/home")
         to get 'ProductType' to be decoded as these following cases:
            - 'ProductJoined'(serial: String, type: String)
            - 'ProductLeft'(serial: String)
         */
        Task {
            await fetchData(serviceURL: service.url)
        }
    }
    

    // MARK: - Private methods
    
    private func fetchData(serviceURL: String) async {
        Task {
            try await self.listenForProductEvents(url: serviceURL)
        }
    }
    
    // MARK: - WebSocket Method to start listening from events
    
    func listenForProductEvents(url: String) async throws {
        guard let url = URL(string: url) else { return }
        
        let socketConnection = URLSession.shared.webSocketTask(with: url)
        let stream = AbstractWebsocketService(task: socketConnection)
        
        Task {
            do {
                for try await message in stream {
                    if case .string(let text) = message {
                        if let data = text.data(using: .utf8) {
                            let decoded = try? JSONDecoder().decode(ProductType.self, from: data)
                            switch decoded {
                            case .productJoined(let decodedProductJoined):
                                print("[DEBUG] - {ws event} | productJoined just arrived on network !", decodedProductJoined)
                                DispatchQueue.main.async {
                                    self.productCellViewModels.append(ProductListCellViewModel(icon: decodedProductJoined.type, produtName: decodedProductJoined.type, productSerial: decodedProductJoined.serial))
                                }
                            case .productLeft(let decodedProductLeft):
                                print("[DEBUG] - {ws event} | productLeft just leaved network 🫣", decodedProductLeft)
                                break // FIXME: ❌ here remove productJoined corresponding to same serial as decodedProductLeft.serial
                            default:
                                print("I was not parsed :(")
                            }
                        }
                    }
                }
            } catch {
                // handle error
                throw error
            }
        }
    }
    
    func getCellViewModel(at indexPath: IndexPath) -> ProductListCellViewModel {
        return productCellViewModels[indexPath.row]
    }
}

