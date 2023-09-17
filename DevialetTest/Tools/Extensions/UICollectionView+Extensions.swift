//
//  UICollectionView+Extensions.swift
//  DevialetTest
//
//  Created by Faustin on 17/09/2023.
//  Source: https://stackoverflow.com/questions/43772984/how-to-show-a-message-when-collection-view-is-empty
//

import UIKit

/*
 This extension helps handling emptyState when collectionView data array is empty
 */
extension UICollectionView {
    
    /*
     This method will display a custom message to indicates user that data has not loaded or is empty
     */
    func setEmptyMessage(_ message: String, textColor: UIColor) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = textColor
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 16)
        messageLabel.sizeToFit()

        self.backgroundView = messageLabel
    }

    func restore() {
        self.backgroundView = nil
    }
}
