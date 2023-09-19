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
    @Published private(set) var isServerRunning: Bool?
    @Published private(set) var timeLesftToNewConnectionString: String?
    
    private var subscriptions = Set<AnyCancellable>()
    
    private var timer: Timer?
    
    
    
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
            await self.fetchData(serviceURL: service.url)
        }
    }
    
    
    // MARK: - Private methods
    
    func fetchData(serviceURL: String) async {
        serverStateService.checkServerRunningState(urlPath: APIServiceEndPoints.serverBaseURL.urlString, completion: { (isValid) in
            if isValid {
                print("[DEBUG] 📡 ✅ - [WS SERVER] | Server is running 🥳")
                print("[DEBUG] 📡 ✅ - [WS SERVER] | URL: \(APIServiceEndPoints.serverBaseURL.urlString) \n")
                
                /*
                 Launch websocketSession to listen to 'productList' endPoint:
                 --> APIServiceEndPoints.listenProductDetail(serial: String) -> "ws://127.0.0.1:8080/home/{serial}")
                 to get 'ProductDetail' to be decoded as these following cases:
                 - 'Music'(serial: String, type: String)
                 - 'Battery'(serial: String)
                 */
                Task {
                    try await self.service.listenForProductEvents(url: serviceURL)
                }
                
                /*
                 deinit timer used to display countdown to relaunch a new connection to the server
                 */
                if self.timer != nil {
                    self.timer?.invalidate()
                    self.timer = nil
                }
            } else {
                print("\n[DEBUG] 📡 ❌ - [WS SERVER] | 🫣 Server seems to be offline, 🙏🏻 please check that you have launched the server in your terminal")
                print("[DEBUG] 📡 ❌ - [WS SERVER] | URL: \(APIServiceEndPoints.serverBaseURL.urlString) is not reachable retrying to connect in 5 seconds...\n")
            }
        })
    }
    
    func setupBindings() {
        /*
         Listen for service.$productCellViewModels changes
         to update collectionView cells
         */
        service.$productCellViewModels.sink { [weak self] _ in
            // Update the UI on the main thread
            DispatchQueue.main.async {
                guard let cells = self?.service.productCellViewModels else { return }
                self?.productCellViewModels = cells
            }
        }.store(in: &subscriptions)
        
        
        /*
         Listen for service.$hasLostConnection changes to retry to connect and display empty collectionView message and reload connection view maybe ?
         */
        service.$isServerRunning.sink { [weak self] isServerRunning in
            self?.isServerRunning = isServerRunning
            if isServerRunning == false {
                print("[DEBUG] - ❌ {websocket server} connection lost", isServerRunning)
                DispatchQueue.main.async {
                    self?.showDebugLogsForNetWork()
                }
            }
        }.store(in: &subscriptions)
    }
    
    func getCellViewModel(at indexPath: IndexPath) -> ProductListCellViewModel {
        return productCellViewModels[indexPath.row]
    }
    
    // MARK: - Private methods
    
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
     Method used to display debug message concerning about trying new connection to network
     */
    func showDebugLogsForNetWork() {
        self.productCellViewModels = []
        
        var totalSecondsLeft: Int = 5
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
            let debugString: String = "[DEBUG] - ⚠️ {server connection lost} next attempt in \(totalSecondsLeft) seconds...\n"
            
            print(debugString)
            
            self.timeLesftToNewConnectionString = debugString
            
            if totalSecondsLeft == 0 {
                totalSecondsLeft = 5
                Task {
                    await self.fetchData(serviceURL: self.service.url)
                }
            } else {
                totalSecondsLeft -= 1
            }
        }
    }
}
