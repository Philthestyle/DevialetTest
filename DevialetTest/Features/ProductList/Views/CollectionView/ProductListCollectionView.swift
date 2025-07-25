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
    // MARK: Parent Controller
    /*
     To trigger the segue to 'ProductDetailViewController'
     when a cell is tapped on.
     */
    private var controller: UIViewController!
    private var timer: Timer?
    private var isServerRunning: Bool?
    
    
    // MARK: - Properties
    
    var collectionView: UICollectionView!
    var cellID = "CollectionCell"
    
    // MARK: - ViewModel
    
    var viewModel = ProductListViewModel(service: ProductListService.shared, serverService: WebsocketServerStateService.shared)
    private var subscriptions = Set<AnyCancellable>()
    
    
    // MARK: - Init methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    convenience init(frame: CGRect, controller: UIViewController) {
        self.init(frame: frame)
        
        self.controller = controller
        
        setupView()
        setupCollectionView()
        setupBindings()
    }
    
    
    // MARK: - Setup Methods
    
    func setupView() {
        backgroundColor = .productJoinedCollectionViewBackground
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
        collectionView.register(ProductCollectionViewCell.self,
                                forCellWithReuseIdentifier: cellID)
        
        // Add CollectionView to current View
        addSubview(collectionView)
    }
    
    func setupBindings() {
        /*
         Listen for viewModel.$productCellViewModels changes
         to trigger reloadData() of the collectionView
         */
        viewModel.$productCellViewModels.sink { [weak self] _ in
            // Update the UI on the main thread
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }.store(in: &subscriptions)
        
        /*
         Listen for viewModel.$isServerRunning changes
         to trigger reloadData() of the collectionView
         */
        viewModel.$isServerRunning.sink { [weak self] isServerOnline in
            // Update the UI on the main thread
            DispatchQueue.main.async {
                self?.isServerRunning = isServerOnline
            }
        }.store(in: &subscriptions)
    }
    
    // MARK: - Segue to 'ProductDetailViewController'
    
    /*
     Trigger the segue to 'ProductDetailViewController' on
     the parent ViewController
     */
    func createSegueToDetailViewController(for indexPath: IndexPath) {
        let detailViewController = ProductDetailViewController()

        let cellViewModel = viewModel.productCellViewModels[indexPath.row]
        let productJoined = ProductJoined(serial: cellViewModel.productSerial, type: cellViewModel.produtName)
        detailViewController.currentProduct = productJoined
        detailViewController.viewModel.product = productJoined
        
        controller.navigationController?.pushViewController(detailViewController, animated: true)
    }
}

// MARK: - UICollectionViewDataSource

extension ProductCollectionView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (self.viewModel.productCellViewModels.count == 0) {
            guard let isServerOnline = self.isServerRunning else { return 0 }
            
            // message to display in case server is running, websocket is connected but we have no product at all that is connected
            let noProductButOnlineString = "No product connected to network for now 🫣, be patient they will show up soon 😎"
            
            let serverIsOfflineString = "❌ Server is not running - check your network 📡"
            
            self.collectionView.setEmptyMessage(isServerOnline ? noProductButOnlineString : serverIsOfflineString, textColor: .white)
        } else {
            self.collectionView.restore()
        }
        
        return viewModel.productCellViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as? ProductCollectionViewCell else { return UICollectionViewCell() }
        
        let cellViewModel = viewModel.getCellViewModel(at: indexPath)
        cell.cellViewModel = cellViewModel
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension ProductCollectionView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        createSegueToDetailViewController(for: indexPath)
    }
    
    // Animate the highlighting of the cell when tapped on
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        if let cell = collectionView.cellForItem(at: indexPath) {
            UIView.animate(withDuration: 0.2, animations: {
                cell.alpha = 0.5
            }) { (_) in
                UIView.animate(withDuration: 0.2) {
                    cell.alpha = 1.0
                }
            }
        }
        return true
    }
}
