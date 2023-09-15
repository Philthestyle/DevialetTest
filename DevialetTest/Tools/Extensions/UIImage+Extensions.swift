//
//  UIImage+Extensions.swift
//  DevialetTest
//
//  Created by Faustin on 15/09/2023.
//

import UIKit

extension UIImageView {
    func loadFrom(url: String) {
        DispatchQueue.global().async { [weak self] in
            guard let url = URL(string: url) else { return }
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
