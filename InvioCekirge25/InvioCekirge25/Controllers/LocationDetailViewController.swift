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
    private let descriptionContainer = UIScrollView()
    private let topGradientContainer = UIView()
    private let locationNameLabel = UILabel()
    private let descriptionLabel = UILabel()
    private var topBlurHeightConstraint: NSLayoutConstraint?
    private let viewOnMapView = ViewOnMapView(frame: .zero, imageName: "map", actionDescription: "Haritada görüntüleyebilirsiniz.", callerDescription: "Bu lokasyonu")

    let cityNameLabel = UILabel() ///We're setting this from coordinator.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isFavorite = isFavoriteLocation()
        configureViewOnMapView()
        configureViewController()
        configureFavoriteIcon()
        configureContainers()
        configureLabels()
        
        configureUI()
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        adjustTopBlurViewHeight()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        adjustTopBlurViewHeight()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.largeTitleDisplayMode = .always
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if self.isMovingFromParent || self.isBeingDismissed {
            coordinator?.coordinatorDidFinish()
        }
    }
    
    func configureViewOnMapView() {
        viewOnMapView.delegate = self
    }
    
    func configureLabels() {
        [locationNameLabel, descriptionLabel, cityNameLabel].forEach({ $0.translatesAutoresizingMaskIntoConstraints = false })
        
        locationNameLabel.textColor = InvioColors.titleLabelColor
        locationNameLabel.font = .systemFont(ofSize: 24, weight: .bold)
        
        cityNameLabel.textColor = InvioColors.secondaryLabelColor
        cityNameLabel.font = .systemFont(ofSize: 16, weight: .light)
        
        descriptionLabel.textColor = .label
        descriptionLabel.numberOfLines = 0
    }
    
    func configureContainers() {
        topGradientContainer.translatesAutoresizingMaskIntoConstraints = false
        topGradientContainer.backgroundColor = .black
        
        descriptionContainer.translatesAutoresizingMaskIntoConstraints = false
        descriptionContainer.backgroundColor = InvioColors.secondaryGroupedBackground
        descriptionContainer.showsVerticalScrollIndicator = false
        descriptionContainer.layer.cornerRadius = 8
        descriptionContainer.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
    
    func configureFavoriteIcon() {
        updateFavoriteIcon()
    }
    
    func configureViewController() {
        view.backgroundColor = InvioColors.groupedBackground
        self.navigationItem.titleView = UIView()
    }
    
    func configureUI() {
        
        [locationImage, topGradientContainer, descriptionContainer, locationNameLabel, cityNameLabel, descriptionLabel, viewOnMapView].forEach { component in
            view.addSubview(component)
        }
        
        NSLayoutConstraint.activate([
            locationImage.topAnchor.constraint(equalTo: view.topAnchor),
            locationImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            locationImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            locationImage.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.45),
            
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
            
            locationNameLabel.topAnchor.constraint(equalTo: topGradientContainer.topAnchor),
            locationNameLabel.leadingAnchor.constraint(equalTo: locationImage.leadingAnchor, constant: 16),
            
            cityNameLabel.bottomAnchor.constraint(equalTo: locationImage.bottomAnchor),
            cityNameLabel.leadingAnchor.constraint(equalTo: locationNameLabel.leadingAnchor),
            
            viewOnMapView.bottomAnchor.constraint(equalTo: topGradientContainer.bottomAnchor),
            viewOnMapView.leadingAnchor.constraint(equalTo: topGradientContainer.leadingAnchor),
            viewOnMapView.trailingAnchor.constraint(equalTo: topGradientContainer.trailingAnchor),
            viewOnMapView.topAnchor.constraint(equalTo: locationNameLabel.bottomAnchor, constant: 8),
            
        ])
        
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
    
    private func addBlurEffectToTop() {
        let topBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterialDark))
        
        topBlurView.translatesAutoresizingMaskIntoConstraints = false
        topBlurView.layer.cornerRadius = 0
        topBlurView.clipsToBounds = true
        
        let topHeight = self.navigationController?.navigationBar.frame.size.height
        view.addSubview(topBlurView)
        
        topBlurHeightConstraint = topBlurView.heightAnchor.constraint(equalToConstant: topHeight ?? self.topbarHeight - 44)

        NSLayoutConstraint.activate([
            topBlurView.topAnchor.constraint(equalTo: view.topAnchor),
            topBlurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBlurView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBlurHeightConstraint!
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
    
    //Ekranin en ustundeki view'in height constraintini ayarlar
    private func adjustTopBlurViewHeight() {
        let topHeight = self.navigationController?.navigationBar.frame.size.height
        topBlurHeightConstraint?.constant = topHeight ?? self.topbarHeight
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
}

//delegate extensions
extension LocationDetailViewController: ViewOnMapViewDelegate {
    func viewOnMapButtonTapped() {
        if let location = location {
            coordinator?.navigateToMapDetail(location)
        }
    }
}
