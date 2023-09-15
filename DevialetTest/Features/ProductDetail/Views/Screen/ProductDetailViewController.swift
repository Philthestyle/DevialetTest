//
//  ProductDetailViewController.swift
//  DevialetTest
//
//  Created by Faustin on 15/09/2023.
//

import Combine
import UIKit

class ProductDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    var currentProduct: ProductJoined?
    var viewModel = ProductDetailViewModel(service: ProductDetailService.shared)
    
    private var subscriptions = Set<AnyCancellable>()
    

    // MARK: - Subviews
    
    private var coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "placeHolder")
        imageView.layer.borderWidth = 0.2
        
        imageView.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        return imageView
    }()
    
    private var musicTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var musicArtistLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var batteryPercentageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .green
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var musicStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    
    // MARK: - View Controller's Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupBindings()
        Task {
            guard let serial = currentProduct?.serial else { return }
            await loadViewModel(url: APIServiceEndPoints.listenProductDetail(serial: serial).urlString)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        // Add all subviews
        addSubviewsViews()
        setupNSLayoutConstraints()
        
        // view
        if let product = self.currentProduct {
            self.title = "\(product.type) - \(product.serial)"
        }
        self.view.backgroundColor = .productDetailVCBackground
    }
    
    
    // MARK: - Add all subviews
    
    private func addSubviewsViews() {
        view.addSubview(batteryPercentageLabel)
        view.addSubview(musicTitleLabel)
        view.addSubview(musicArtistLabel)
        view.addSubview(coverImageView)
        
        view.addSubview(musicStackView)
    
        // add 'productNameLabel' & 'serialLabel' into 'labelStackView'
        musicStackView.addArrangedSubview(self.coverImageView)
        musicStackView.addArrangedSubview(self.musicTitleLabel)
        musicStackView.addArrangedSubview(self.musicArtistLabel)
    }
    
    
    // MARK: - setupNSLayoutConstraints
    
    private func setupNSLayoutConstraints() {
        // 'coverImageView'
        NSLayoutConstraint.activate([
            coverImageView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 12),
            coverImageView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 12),
            coverImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        // 'musicStackView'
        NSLayoutConstraint.activate([
            musicStackView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 12),
            musicStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: UIScreen.main.bounds.height / 4),
            musicStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            musicStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // 'batteryPercentageLabel'
        NSLayoutConstraint.activate([
            batteryPercentageLabel.heightAnchor.constraint(equalToConstant: 30),
            batteryPercentageLabel.bottomAnchor.constraint(equalTo: musicStackView.bottomAnchor, constant: 90),
            batteryPercentageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}

// MARK: - Load View Model & setup Bindings

extension ProductDetailViewController {
    /*
     Launch websocketSession to listen to 'productDetail' endPoint:
        --> APIServiceEndPoints.listenProductDetail(serial: \(productSerial) -> "ws://127.0.0.1:8080/home/\(serial)")
     to get 'ProductDetail' to be decoded as these following cases:
        - 'Music'(title: String, cover: String, artist: String)
        - 'Battery'(percent: Int)
     */
    func loadViewModel(url: String) async {
        Task {
            await viewModel.fetchData(url: url)
        }
    }
    
    
    /*
     Bindings to listen to viewModel's following properties:
        - viewModel.$music
        - viewModel.$battery
     */
    
    func setupBindings() {
        /*
         viewModel.$music has changed -> need to update these following labels:
            - 'self?.batteryPercentageLabel.text'
            - 'self?.musicArtistLabel.text'
         */
        viewModel.$music.sink { [weak self] music in
            // Update the UI on the main thread
            DispatchQueue.main.async {
               // reload data of music section here
                self?.musicTitleLabel.text = "\(self?.viewModel.music?.title ?? "no title error")"
                self?.musicArtistLabel.text = "\(self?.viewModel.music?.artist ?? "no artist error")"
                
                // reload cover here
                guard let urlString = self?.viewModel.music?.cover else { return }
                self?.coverImageView.loadFrom(url: urlString)
            }
        }.store(in: &subscriptions)

        /*
         viewModel.$battery has changed -> need to update following label:
            - 'self?.batteryPercentageLabel.text'
         */
        viewModel.$battery.sink { [weak self] state in
            // Update the UI on the main thread
            DispatchQueue.main.async {
                self?.batteryPercentageLabel.text = "\(self?.viewModel.battery?.percent ?? 0)%"
            }
        }.store(in: &subscriptions)
        
        
        /*
         Dismiss viewController depending on currentProduct has left network, could be:
            - no more battery (<1%) for 'Mania' only
            - productLeft event (for 'Mania' or 'Phantom II')
         */
        viewModel.$isCurrentProductOnline.sink { [weak self] state in
            // Update the UI on the main thread
            DispatchQueue.main.async {
                if self?.viewModel.isCurrentProductOnline == false {
                    print("[DEBUG] - ⏮️ {navigation controller -> popToRoot} 🟠 current Product went offline")
                    self?.navigationController?.popToRootViewController(animated: true)
                }
            }
        }.store(in: &subscriptions)
    }
}
