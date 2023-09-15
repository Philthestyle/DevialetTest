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
    let serverStateService: WebsocketServerStateService!
    
    @Published private(set) var productCellViewModels: [ProductListCellViewModel] = []
    
    // MARK: - Init service & fetchData
    
    public init(service: ProductListService, serverService: WebsocketServerStateService) {
        self.service = service
        self.serverStateService = serverService
        
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
        serverStateService.checkServerRunningState(urlPath: APIServiceEndPoints.serverBaseURL.urlString, completion: { (isValid) in
            if isValid {
                print("[DEBUG] 📡 ✅ - [WS SERVER] | Server is running 🥳")
                print("[DEBUG] 📡 ✅ - [WS SERVER] | URL: \(APIServiceEndPoints.serverBaseURL.urlString) \n")
                Task {
                    try await self.listenForProductEvents(url: serviceURL)
                }
            } else {
                print("[DEBUG] 📡 ❌ - [WS SERVER] | Server seems to be offline 🫣")
                print("[DEBUG] 📡 ❌ - [WS SERVER] | URL: \(APIServiceEndPoints.serverBaseURL.urlString) is not reachable \n")
            }
        })
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
    
    
    func getCellViewModel(at indexPath: IndexPath) -> ProductListCellViewModel {
        return productCellViewModels[indexPath.row]
    }
}

