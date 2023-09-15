//
//  ProductListViewController.swift
//  DevialetTest
//
//  Created by Faustin on 15/09/2023.
//

import UIKit

class ProductListViewController: UIViewController {
    // MARK: - Properties
    
    var collectionView: ProductCollectionView!
    
    // MARK: - View Controller's Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupCollectionView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
 
    // MARK: - Setup UI Methods
    
    private func setupView() {
        self.title = "Home"
        self.view.backgroundColor = .productListVCBackground
    }
    
    /*
     Setup collectionView wich represents the list of all Products (as struct -> 'ProductJoined') being online
     */
    func setupCollectionView() {
        collectionView = ProductCollectionView(frame: view.frame, controller: self)
        view.addSubview(collectionView)
    }
    
    // MARK: - Tests with mocks
    // FIXME: ❌ need to remove this following method having tested if this screen works normally with its collectionView and mock data
    func creatCellViewModelArray(for products: [ProductJoined]) -> [ProductListCellViewModel] {
        products.map { ProductListCellViewModel(icon: $0.type, produtName: $0.type, productSerial: $0.serial) }
    }
}
