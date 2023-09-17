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

class ProductListService: ObservableObject, ProductListServiceProtocol {
    
    @Published private(set) var productCellViewModels: [ProductListCellViewModel] = []
    
    static let shared = ProductListService()
    var url: String = APIServiceEndPoints.listenProductEvents.urlString
    var socketConnection: URLSessionWebSocketTask?
    
    init() {
        socketConnection = URLSession.shared.webSocketTask(with: URL(string: url)!)
    }
    
    // MARK: - WebSocket Method to start listening from events
    
    func listenForProductEvents(url: String) async throws {
        guard let url = URL(string: url) else { return }
        let socketConnection = URLSession.shared.webSocketTask(with: url)
        let stream = AbstractWebsocketService(task: socketConnection)
        
        print("[DEBUG] - 🟢 {Start} websocket for 'listenForProductEvents' with url: \(url)")
        Task {
            do {
                for try await message in stream {
                    if case .string(let text) = message {
                        if let data = text.data(using: .utf8) {
                            let decoded = try? JSONDecoder().decode(ProductType.self, from: data)
                            switch decoded {
                            case .productJoined(let decodedProductJoined):
                                print("[DEBUG] - {ws event} ✅ 'productJoined' decoded -->", decodedProductJoined)
                                DispatchQueue.main.async {
                                    self.productCellViewModels.append(ProductListCellViewModel(icon: decodedProductJoined.type, produtName: decodedProductJoined.type, productSerial: decodedProductJoined.serial))
                                }
                            case .productLeft(let decodedProductLeft):
                                print("[DEBUG] - {ws event} ❌ 'productLeft' decoded --> ", decodedProductLeft)
                                self.filterDataArrays(serial: decodedProductLeft.serial, startDate: Date()) { doneInMilliseconds in
                                    print("[DEBUG] - {filtering data arrays} for 'products' & 'productCellViewModels' - done in: \(doneInMilliseconds) ⏱️")
                                }
                            default:
                                print("[DEBUG] - {ws event} ⚠️ 'ProductType' was not parsed")
                            }
                        }
                    }
                }
            } catch {
                // handle error
                print("[DEBUG] - 🔴 {ProductListViewModel -> listenForProductEvents} .failure with error: ", error)
                throw error
            }
            print("[DEBUG] - 🔴 {AbstractWebsocketService -> socketConnection} stream ended")
        }
    }
    
    
    /*
     Method used to return
     */
    private func filterDataArrays(serial: String, startDate: Date, completion: @escaping (_ executionDuration: String) -> Void) {
        DispatchQueue.main.async {
            self.productCellViewModels = self.productCellViewModels.filter { $0.productSerial != serial }
            /*
             get method execution duration to see if its optimized filtering array like this
             */
            let endDate: Date = Date()
            let formatter = DateComponentsFormatter()
            if let duration = formatter.difference(from: startDate, to: endDate) {
                completion(duration)
            } else {
                completion("error getting duration")
            }
        }
    }
}
