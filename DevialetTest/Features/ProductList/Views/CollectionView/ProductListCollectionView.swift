//
//  ProductListCollectionView.swift
//  DevialetTest
//
//  Created by Faustin on 15/09/2023.
//

import Combine // used to listen viewModel.$productCellViewModels
import Foundation
import UIKit

class ProductCollectionView: UIView {
    // MARK: - Properties
    
    var collectionView: UICollectionView!
    var cellID = "CollectionCell"
    
    // MARK: - ViewModel
    
    var viewModel = ProductListViewModel()

    
    // MARK: - Init methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    convenience init(frame: CGRect, controller: UIViewController) {
        self.init(frame: frame)
        
        setupView()
        setupCollectionView()
        
        viewModel.creatCellViewModelArray(for: ProductJoined.MOCK_ProductJoined)
    }
    
    // MARK: - Setup Methods
    
    func setupView() {
        backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }
    
    // Setup the collection view
    func setupCollectionView() {
        let horizontalInsets: CGFloat = 22
        let viewWidth = frame.width
        
        // Cell Size
        let cellsPerRow: CGFloat = 1
        let totalHorizontalInsets = horizontalInsets + cellsPerRow
        let cellWidth = (viewWidth - totalHorizontalInsets) / cellsPerRow
        let cellHeight = UIScreen.main.bounds.height / 8.5
        
        // CollectionView Layout
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(
            top: 22,
            left: horizontalInsets / 2,
            bottom: 0,
            right: horizontalInsets / 2
        )
        layout.minimumLineSpacing = 12
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        
        // Instantiate CollectionView
        collectionView = UICollectionView(
            frame: frame, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        
        // Delegates
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // Register the CollectionView's cell
        collectionView.register(ProductCollectionViewCell.self,forCellWithReuseIdentifier: cellID)
        
        // Add CollectionView to current View
        addSubview(collectionView)
    }
}

// MARK: - UICollectionViewDataSource

extension ProductCollectionView: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.productCellViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as? ProductCollectionViewCell else { return UICollectionViewCell() }
        
        let cellViewModel = viewModel.getCellViewModel(at: indexPath)
        cell.cellViewModel = cellViewModel
        
        return cell
    }
}
