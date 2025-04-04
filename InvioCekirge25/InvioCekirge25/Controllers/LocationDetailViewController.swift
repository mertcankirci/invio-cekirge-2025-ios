//
//  LocationDetailViewController.swift
//  InvioCekirge25
//
//  Created by Mertcan Kırcı on 1.04.2025.
//

import UIKit

protocol LocationDetailVCDelegate: AnyObject {
    func didUpdateFavoriteStatus(for location: LocationModel, isFavorite: Bool)
}

class LocationDetailViewController: UIViewController {

    weak var coordinator: LocationDetailCoordinator?
    weak var delegate: LocationDetailVCDelegate?
    
    private let persistenceService = PersistenceService.shared
    private var isFavorite: Bool = false
    
    var location: LocationModel? {
        didSet {
            downloadImage()
            setLocationLabel()
            setDescriptionLabel()
        }
    }
    
    private let locationImage = CekirgeGradientImageView(frame: .zero)
    private let descriptionContainer = UIView()
    private let topGradientContainer = UIView()
    private let locationNameLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let viewOnMapContainer = UIView()
    private let viewOnMapButton = UIButton()
    private let viewOnMapCallerLabel = UILabel()
    private let viewOnMapActionLabel = UILabel()
    private let viewOnMapImage = UIImageView()
    private let viewOnMapImageContainer = UIView() /// Container to hold viewOnMapImage
    let cityNameLabel = UILabel() ///We're setting this from coordinator.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isFavorite = isFavoriteLocation()
        configureViewController()
        configureFavoriteIcon()
        configureContainers()
        configureLabels()
        configureButtons()
        configureImages()
        
        configureUI()
    }
    
    func configureImages() {
        viewOnMapImage.translatesAutoresizingMaskIntoConstraints = false
        viewOnMapImage.image = UIImage(systemName: "map")
        viewOnMapImage.tintColor = .accent
        viewOnMapImage.contentMode = .scaleAspectFit
        viewOnMapImage.isUserInteractionEnabled = false
    }
    
    func configureButtons() {
        viewOnMapButton.translatesAutoresizingMaskIntoConstraints = false
        viewOnMapButton.setTitle("Harita", for: .normal)
        viewOnMapButton.layer.cornerRadius = 15
        viewOnMapButton.layer.masksToBounds = true
        viewOnMapButton.backgroundColor = .white.withAlphaComponent(0.3)
        viewOnMapButton.titleLabel?.textColor = .white
        viewOnMapButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        viewOnMapButton.addTarget(self, action: #selector(viewOnMapButtonTapped), for: .touchUpInside)
    }
    
    func configureLabels() {
        [locationNameLabel, descriptionLabel, cityNameLabel, viewOnMapCallerLabel, viewOnMapActionLabel].forEach({ $0.translatesAutoresizingMaskIntoConstraints = false })
        
        locationNameLabel.textColor = .white
        locationNameLabel.font = .systemFont(ofSize: 24, weight: .bold)
        
        cityNameLabel.textColor = .white.withAlphaComponent(0.7)
        cityNameLabel.font = .systemFont(ofSize: 16, weight: .light)
        
        descriptionLabel.textColor = .label
        descriptionLabel.numberOfLines = 0
        
        viewOnMapCallerLabel.text = "Bu lokasyonu"
        viewOnMapCallerLabel.textColor = .white
        viewOnMapCallerLabel.font = .systemFont(ofSize: 14, weight: .regular)
        
        viewOnMapActionLabel.text = "Haritada görüntüleyebilirsin."
        viewOnMapActionLabel.textColor = .white.withAlphaComponent(0.7)
        viewOnMapActionLabel.font = .systemFont(ofSize: 12, weight: .light)
    }
    
    func configureContainers() {
        topGradientContainer.translatesAutoresizingMaskIntoConstraints = false
        topGradientContainer.backgroundColor = .black
        
        descriptionContainer.translatesAutoresizingMaskIntoConstraints = false
        descriptionContainer.backgroundColor = .secondarySystemGroupedBackground
        descriptionContainer.layer.cornerRadius = 8
        descriptionContainer.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        viewOnMapContainer.translatesAutoresizingMaskIntoConstraints = false
        
        viewOnMapImageContainer.translatesAutoresizingMaskIntoConstraints = false
        viewOnMapImageContainer.layer.cornerRadius = 8
        viewOnMapImageContainer.layer.masksToBounds = true
        viewOnMapImageContainer.backgroundColor = .gray.withAlphaComponent(0.8)
    }
    
    func configureFavoriteIcon() {
        updateFavoriteIcon()
    }
    
    func configureViewController() {
        view.backgroundColor = .systemGroupedBackground
        self.navigationItem.titleView = UIView()
    }
    
    func configureUI() {
        
        [locationImage, topGradientContainer, descriptionContainer, locationNameLabel, cityNameLabel, descriptionLabel, viewOnMapContainer, viewOnMapImageContainer, viewOnMapActionLabel, viewOnMapCallerLabel, viewOnMapButton, viewOnMapImage].forEach { component in
            view.addSubview(component)
        }
        
        NSLayoutConstraint.activate([
            locationImage.topAnchor.constraint(equalTo: view.topAnchor),
            locationImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            locationImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            locationImage.heightAnchor.constraint(equalToConstant: view.bounds.height * 0.6),
            
            topGradientContainer.topAnchor.constraint(equalTo: locationImage.bottomAnchor),
            topGradientContainer.leadingAnchor.constraint(equalTo: locationImage.leadingAnchor),
            topGradientContainer.trailingAnchor.constraint(equalTo: locationImage.trailingAnchor),
            topGradientContainer.heightAnchor.constraint(equalToConstant: 100),
            
            descriptionContainer.topAnchor.constraint(equalTo: topGradientContainer.bottomAnchor),
            descriptionContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            descriptionContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            descriptionContainer.bottomAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 12),
            
            descriptionLabel.topAnchor.constraint(equalTo: descriptionContainer.topAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: descriptionContainer.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: descriptionContainer.trailingAnchor, constant: -16),
            
            locationNameLabel.topAnchor.constraint(equalTo: locationImage.bottomAnchor, constant: 2),
            locationNameLabel.leadingAnchor.constraint(equalTo: locationImage.leadingAnchor, constant: 16),
            
            cityNameLabel.bottomAnchor.constraint(equalTo: locationImage.bottomAnchor, constant: -2),
            cityNameLabel.leadingAnchor.constraint(equalTo: locationNameLabel.leadingAnchor),
            
            viewOnMapContainer.bottomAnchor.constraint(equalTo: topGradientContainer.bottomAnchor),
            viewOnMapContainer.leadingAnchor.constraint(equalTo: topGradientContainer.leadingAnchor),
            viewOnMapContainer.trailingAnchor.constraint(equalTo: topGradientContainer.trailingAnchor),
            viewOnMapContainer.topAnchor.constraint(equalTo: locationNameLabel.bottomAnchor, constant: 8),
            
            viewOnMapImageContainer.leadingAnchor.constraint(equalTo: viewOnMapContainer.leadingAnchor, constant: 16),
            viewOnMapImageContainer.centerYAnchor.constraint(equalTo: viewOnMapContainer.centerYAnchor),
            viewOnMapImageContainer.heightAnchor.constraint(equalToConstant: 44),
            viewOnMapImageContainer.widthAnchor.constraint(equalToConstant: 44),
            
            viewOnMapImage.centerXAnchor.constraint(equalTo: viewOnMapImageContainer.centerXAnchor),
            viewOnMapImage.centerYAnchor.constraint(equalTo: viewOnMapImageContainer.centerYAnchor),
            viewOnMapImage.widthAnchor.constraint(equalToConstant: 32),
            viewOnMapImage.heightAnchor.constraint(equalToConstant: 32),
            
            viewOnMapCallerLabel.bottomAnchor.constraint(equalTo: viewOnMapImageContainer.centerYAnchor),
            viewOnMapCallerLabel.leadingAnchor.constraint(equalTo: viewOnMapImageContainer.trailingAnchor, constant: 8),
            
            viewOnMapActionLabel.topAnchor.constraint(equalTo: viewOnMapImageContainer.centerYAnchor),
            viewOnMapActionLabel.leadingAnchor.constraint(equalTo: viewOnMapCallerLabel.leadingAnchor),
            
            viewOnMapButton.trailingAnchor.constraint(equalTo: viewOnMapContainer.trailingAnchor, constant: -16),
            viewOnMapButton.centerYAnchor.constraint(equalTo: viewOnMapContainer.centerYAnchor),
            viewOnMapButton.widthAnchor.constraint(equalToConstant: 64),
            viewOnMapButton.heightAnchor.constraint(equalToConstant: 32),
        ])
        
        addBlurEffectToViewOnMapContainer()
        addBlurEffectToTop()
    }

}

//custom functions
extension LocationDetailViewController {
    private func updateFavoriteIcon() {
        let imageName = isFavorite ? "heart.fill" : "heart"
        let heartImage = UIImage(systemName: imageName)
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: heartImage,
            style: .plain,
            target: self,
            action: #selector(favButtonTapped)
        )
    }
    
    private func addBlurEffectToViewOnMapContainer() {
        let blurEffect = UIBlurEffect(style: .regular)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.clipsToBounds = true
        
        viewOnMapContainer.addSubview(blurView)
        
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: viewOnMapContainer.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: viewOnMapContainer.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: viewOnMapContainer.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: viewOnMapContainer.bottomAnchor)
        ])
    }
    
    private func addBlurEffectToTop() {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.layer.cornerRadius = 0
        blurView.clipsToBounds = true

        view.addSubview(blurView)

        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: view.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    private func setLocationLabel() {
        locationNameLabel.text = location?.name
    }
    
    private func setDescriptionLabel() {
        descriptionLabel.text = location?.description
    }
    
    private func downloadImage() {
        locationImage.downloadImage(from: location?.image)
    }
    
    private func isFavoriteLocation() -> Bool {
        guard let location = location else { return false }
        return persistenceService.isFavorite(location: location)
    }
    
    private func handleFavoritePersistence() {
        if isFavorite {
            deleteFavoriteLocation()
        } else {
            saveFavoriteLocation()
        }
        UIHelper.successHapticFeedback()
    }
    
    private func saveFavoriteLocation() {
        guard let location = location else { return }
        do {
            try persistenceService.saveFavLocation(for: location)
        } catch {
            self.presentAlert(errorMessage: error.localizedDescription)
        }
    }
    
    private func deleteFavoriteLocation() {
        guard let location = location else { return }
        do {
            try persistenceService.deleteFavLocation(for: location)
        } catch {
            self.presentAlert(errorMessage: error.localizedDescription)
        }
    }
    
    @objc
    func favButtonTapped() {
        handleFavoritePersistence()
        isFavorite.toggle()
        updateFavoriteIcon()
        
        if let location = location {
            delegate?.didUpdateFavoriteStatus(for: location, isFavorite: isFavorite)
        }
    }
    
    @objc func viewOnMapButtonTapped() {
        if let location = location {
            coordinator?.navigateToMapDetail(location)
        }
    }
}
