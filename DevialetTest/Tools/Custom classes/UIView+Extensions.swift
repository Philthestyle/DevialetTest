//
//  UIView+Extensions.swift
//  DevialetTest
//
//  Created by Faustin on 16/09/2023.
//  Source: https://github.com/Kous92/Test-MVVM-Combine-UIKit-iOS/blob/main/Test%20Combine/Extensions/UIViewExtension.swift
//

import Foundation
import UIKit

/*
 This extension allows to add a spinner to an UIView
 */
extension UIView {
    static let loadingViewTag = 1938123987
    
    func showLoading(style: UIActivityIndicatorView.Style = .large, color: UIColor = .red) {
        var loading = viewWithTag(UIImageView.loadingViewTag) as? UIActivityIndicatorView
        
        if loading == nil {
            loading = UIActivityIndicatorView(style: style)
            loading?.color = .white
        }

        loading?.translatesAutoresizingMaskIntoConstraints = false
        loading!.startAnimating()
        loading!.hidesWhenStopped = true
        loading?.tag = UIView.loadingViewTag
        addSubview(loading!)
        loading?.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        loading?.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }

    func stopLoading() {
        let loading = viewWithTag(UIView.loadingViewTag) as? UIActivityIndicatorView
        loading?.stopAnimating()
        loading?.removeFromSuperview()
    }
}
