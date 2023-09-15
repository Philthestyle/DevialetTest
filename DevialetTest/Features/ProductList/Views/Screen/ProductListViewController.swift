//
//  ProductListViewController.swift
//  DevialetTest
//
//  Created by Faustin on 15/09/2023.
//

import UIKit

class ProductListViewController: UIViewController {

    // MARK: - View Controller's Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
 
    // MARK: - Setup UI Methods
    
    private func setupView() {
        self.title = "Home"
    }
}
