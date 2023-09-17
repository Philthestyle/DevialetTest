//
//  CacheImageView.swift
//  DevialetTest
//
//  Created by Faustin on 15/09/2023.
//  source: https://stackoverflow.com/questions/40873685/how-to-cache-images-using-urlsession-in-swift
//


import UIKit

/*
 Used to download image from url quickly and reload them from cache if already cached
 */
final class ImageStore: NSObject {
    static let imageCache = NSCache<NSString, UIImage>()
}

final class CacheImageView: UIImageView {

    // MARK: - Properties
    var imageURLString: String?
    
    // MARK: - Methods
    func downloadImageFrom(urlString: String, imageMode: UIView.ContentMode) {
        guard let url = URL(string: urlString) else { return }
        
        // display loader (UIActivityIndicatorView)
        self.showLoading()
        
        self.downloadImageFrom(url: url, imageMode: imageMode, startDate: Date()) { usingNSCache in
            DispatchQueue.main.async {
                self.stopLoading()
                
                usingNSCache ? print("\n[DEBUG] | 💶 {NSCache getting} 'coverImageView' for forKey: \(url.absoluteString as NSString) \n") : print("\n[DEBUG] | ⏬ {URLSession 'dowloading'} 'coverImageView' for url: \n    --> \(url)")
            }
        }
    }

    private func downloadImageFrom(url: URL, imageMode: UIView.ContentMode, startDate: Date, completion: @escaping (_ usingNSCache: Bool) -> Void) {
        contentMode = imageMode
        if let cachedImage = ImageStore.imageCache.object(forKey: url.absoluteString as NSString) {
            DispatchQueue.main.async {
                self.image = cachedImage
                
                completion(true)
            }
        } else {
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else { return }
                
                DispatchQueue.main.async {
                    let imageToCache = UIImage(data: data)
                    // save image using NSCache
                    ImageStore.imageCache.setObject(imageToCache!, forKey: url.absoluteString as NSString)
                    self.image = imageToCache
                    
                    completion(false)
                }
            }.resume()
        }
    }
}
