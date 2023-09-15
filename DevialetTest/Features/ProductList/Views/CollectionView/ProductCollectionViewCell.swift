//
//  ProductCollectionViewCell.swift
//  DevialetTest
//
//  Created by Faustin on 15/09/2023.
//

import Foundation
import UIKit

class ProductCollectionViewCell: UICollectionViewCell {
    
    // MARK: - View Model
    
    // Populate the UI
    var cellViewModel: ProductListCellViewModel? {
        didSet {
            guard let cellVM = cellViewModel else { return }
            
            productImageView.image = UIImage(named: cellVM.produtName)
            productNameLabel.text = cellVM.produtName.uppercased()
            serialLabel.text = cellVM.productSerial.uppercased()
        }
    }
    
    // MARK: - Subviews
    
    private var productImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var productNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var serialLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var labelStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    
    // MARK: - Init Methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    
    // MARK: - Set UI of cell
    
    private func setupUI() {
        // Add all subviews
        addSubviewsViews()
        
        // Setup all NSLayoutConstraints
        setupNSLayoutConstraints()
      
        // Setup cell UI
        backgroundColor = #colorLiteral(red: 0.1137256995, green: 0.1137253419, blue: 0.1050826684, alpha: 1)
        layer.cornerRadius = 26
    }
    
    
    // MARK: - Add all subviews
    
    private func addSubviewsViews() {
        addSubview(productImageView)
        addSubview(productNameLabel)
        addSubview(serialLabel)
        addSubview(labelStack)
        
        labelStack.addArrangedSubview(productNameLabel)
        labelStack.addArrangedSubview(serialLabel)
    }
    
    
    // MARK: - setupNSLayoutConstraints
    
    private func setupNSLayoutConstraints() {
        // 'productImageView'
        NSLayoutConstraint.activate([
            productImageView.widthAnchor.constraint(equalToConstant: frame.width / 5),
            productImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            productImageView.heightAnchor.constraint(equalToConstant: frame.width / 5),
            productImageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        // 'labelStack'
        NSLayoutConstraint.activate([
            labelStack.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: 12),
            labelStack.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
