//
//  CityTableViewCell.swift
//  InvioCekirge25
//
//  Created by Mertcan Kırcı on 27.03.2025.
//

import UIKit

protocol CityTableViewCellDelegate: AnyObject {
    func didTapNavigationButton(from city: CityModel)
}

class CityTableViewCell: UITableViewCell {
    
    static let reuseId = "CityTableViewCell"
    
    let cityLabel = UILabel()
    let locationLabel = UILabel()
    let navigationButton = UIButton()
    let includesLocationImage = UIImageView()
    let includesLocationContainer = UIView()
    let cityImageView = CekirgeGradientImageView(frame: .zero)
    
    private let locationImageConfiguration = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
    
    weak var delegate: CityTableViewCellDelegate?
    private var city: CityModel?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureLabels()
        configureButton()
        configureImageViews()
        
        configureCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cityLabel.text = nil
        cityImageView.resetImage()
        includesLocationImage.image = nil
    }
    
    func configureLabels() {
        cityLabel.translatesAutoresizingMaskIntoConstraints = false
        cityLabel.font = .systemFont(ofSize: 18, weight: .bold)
        cityLabel.textColor = .white
        
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.font = .systemFont(ofSize: 12, weight: .light)
        locationLabel.textColor = .white.withAlphaComponent(0.7)
    }
    
    func configureButton() {
        navigationButton.translatesAutoresizingMaskIntoConstraints = false
        navigationButton.setImage(UIImage(systemName: "mappin"), for: .normal)
        navigationButton.imageView?.contentMode = .scaleAspectFit
        
        navigationButton.layer.cornerRadius = 16
        navigationButton.layer.masksToBounds = true
        navigationButton.backgroundColor = .gray.withAlphaComponent(0.5)
        
        navigationButton.addTarget(self, action: #selector(didTapNavigationButton), for: .touchUpInside)
    }
    
    func configureImageViews() {
        cityImageView.translatesAutoresizingMaskIntoConstraints = false
        cityImageView.layer.cornerRadius = 8
        cityImageView.layer.masksToBounds = true
        
        includesLocationContainer.translatesAutoresizingMaskIntoConstraints = false
        includesLocationContainer.layer.cornerRadius = 16
        includesLocationContainer.layer.masksToBounds = true
        includesLocationContainer.backgroundColor = .gray.withAlphaComponent(0.5)
        
        includesLocationImage.translatesAutoresizingMaskIntoConstraints = false
        includesLocationImage.contentMode = .scaleAspectFit
        includesLocationImage.isUserInteractionEnabled = false
        includesLocationImage.tintColor = .accent
    }
    
    func configureCell() {
        backgroundColor = .clear
        selectionStyle = .none
        [cityImageView, cityLabel, locationLabel, navigationButton, includesLocationContainer].forEach { view in
            contentView.addSubview(view)
        }
        
        includesLocationContainer.addSubview(includesLocationImage)
        
        NSLayoutConstraint.activate([
            cityImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cityImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cityImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            cityImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            cityImageView.heightAnchor.constraint(equalToConstant: 80),
            
            includesLocationContainer.leadingAnchor.constraint(equalTo: cityImageView.leadingAnchor, constant: 16),
            includesLocationContainer.centerYAnchor.constraint(equalTo: cityImageView.centerYAnchor),
            includesLocationContainer.widthAnchor.constraint(equalToConstant: 32),
            includesLocationContainer.heightAnchor.constraint(equalToConstant: 32),
            
            includesLocationImage.centerXAnchor.constraint(equalTo: includesLocationContainer.centerXAnchor),
            includesLocationImage.centerYAnchor.constraint(equalTo: includesLocationContainer.centerYAnchor),
            includesLocationImage.widthAnchor.constraint(equalToConstant: 16),
            includesLocationImage.heightAnchor.constraint(equalToConstant: 16),
            
            cityLabel.leadingAnchor.constraint(equalTo: includesLocationContainer.trailingAnchor, constant: 12),
            cityLabel.bottomAnchor.constraint(equalTo: cityImageView.bottomAnchor, constant: -8),
            
            locationLabel.leadingAnchor.constraint(equalTo: cityLabel.leadingAnchor),
            locationLabel.bottomAnchor.constraint(equalTo: cityLabel.topAnchor, constant: -2),
            
            navigationButton.trailingAnchor.constraint(equalTo: cityImageView.trailingAnchor, constant: -16),
            navigationButton.centerYAnchor.constraint(equalTo: cityImageView.centerYAnchor),
            navigationButton.widthAnchor.constraint(equalToConstant: 32),
            navigationButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    func set(city: CityModel) {
        cityLabel.text = city.city
        locationLabel.text = "\(city.locations.count) lokasyon"
        self.city = city
        cityImageView.downloadImage(from: city.cellImage)
        
        if city.locations.count <= 0 {
            includesLocationImage.isHidden = true
            includesLocationContainer.isHidden = true
        } else {
            includesLocationImage.image = UIImage(systemName: "plus", withConfiguration: locationImageConfiguration)
        }
    }
    
    func onSelectPerform(isExpanded: Bool) {
        let symbolName = isExpanded ? "minus" : "plus"
        let newImage = UIImage(systemName: symbolName, withConfiguration: locationImageConfiguration)
        
        UIView.transition(with: includesLocationImage,
                          duration: 0.4,
                          options: .transitionCrossDissolve,
                          animations: { [weak self] in
            guard let self = self else { return }
            self.includesLocationImage.image = newImage
            self.adjustImagesMaskedCorners(isExpanded)
        },
                          completion: nil)
    }
    
    func adjustImagesMaskedCorners(_ isExpanded: Bool) {
        if isExpanded {
            self.cityImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else {
            self.cityImageView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
        }
    }
    
}

extension CityTableViewCell {
    @objc func didTapNavigationButton() {
        guard let city = city else { return }
        delegate?.didTapNavigationButton(from: city)
    }
}
