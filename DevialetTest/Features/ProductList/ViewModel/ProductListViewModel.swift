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
    // TODO: add service here -> could be ProductListService (need to create this service too in another file)
    
    // FIXME: ⚠️ here I need to use @Published private(set) var to make ProductListViewController able to bind / .sink this property and reload collectionView data
    var productCellViewModels: [ProductListCellViewModel] = []
    
    // TODO: add init with future 'service' as argument
    // TODO: call method to fetch data and feed 'productCellViewModels' array

    // MARK: - Data getter methods (called from 'ProductListViewController')
    
    func getCellViewModel(at indexPath: IndexPath) -> ProductListCellViewModel {
        productCellViewModels[indexPath.row]
    }
    
    // FIXME: ❌ need to remove this following method having tested if this screen works normally with its collectionView and mock data
    func creatCellViewModelArray(for products: [ProductJoined]) {
        productCellViewModels = products.map { ProductListCellViewModel(icon: $0.type, produtName: $0.type, productSerial: $0.serial) }
    }
}
