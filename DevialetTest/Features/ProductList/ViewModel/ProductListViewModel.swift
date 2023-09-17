//
//  ProductListViewModel.swift
//  DevialetTest
//
//  Created by Faustin on 15/09/2023.
//

import Foundation
import Combine

class ProductListViewModel: ObservableObject {
    
    // MARK: - Properties
    let service: ProductListService!
    let serverStateService: WebsocketServerStateService!
    
    @Published private(set) var productCellViewModels: [ProductListCellViewModel] = []
    
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Init service & fetchData
    
    public init(service: ProductListService, serverService: WebsocketServerStateService) {
        self.service = service
        self.serverStateService = serverService
        
        setupBindings()

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
                    try await self.service.listenForProductEvents(url: serviceURL)
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
    
    /*
     Listen for viewModel.$productCellViewModels changes
     to trigger reloadData() of the collectionView
     */
    func setupBindings() {
        service.$productCellViewModels.sink { [weak self] _ in
            // Update the UI on the main thread
            DispatchQueue.main.async {
                guard let cells = self?.service.productCellViewModels else { return }
                self?.productCellViewModels = cells
            }
        }.store(in: &subscriptions)
    }
    
    func getCellViewModel(at indexPath: IndexPath) -> ProductListCellViewModel {
        return productCellViewModels[indexPath.row]
    }
}

