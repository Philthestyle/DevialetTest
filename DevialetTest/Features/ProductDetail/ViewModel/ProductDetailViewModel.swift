//
//  ProductDetailViewModel.swift
//  DevialetTest
//
//  Created by Faustin on 15/09/2023.
//

import Combine
import Foundation
import UIKit

class ProductDetailViewModel: ObservableObject {
   
    // MARK: - Properties
    var product: ProductJoined = ProductJoined.MOCK_ProductJoined.randomElement()! // FIXME: ❌ don't forget to remove mocks value here
    
    // MARK: - Binding properties
    
    @Published private(set) var music: Music = ProductDetail.MOCK_Music // FIXME: ❌ don't forget to remove mocks value here
    @Published private(set) var battery: Battery? = ProductDetail.MOCK_Battery // FIXME: ❌ don't forget to remove mocks value here
}
