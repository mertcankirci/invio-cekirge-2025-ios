//
//  LocationListCollectionViewCell.swift
//  InvioCekirge25
//
//  Created by Mertcan Kırcı on 28.03.2025.
//

import UIKit

class LocationListCollectionViewCell: UICollectionViewCell {
    static let reuseId = "LocationListCollectionViewCell"
    
    let locationImageView = CekirgeGradientImageView(frame: .zero)
    let locationLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLabel()
        configureImageView()
        configureCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func configureCell() {
        contentView.backgroundColor = .clear
        
        contentView.addSubview(locationImageView)
        contentView.addSubview(locationLabel)
        
        NSLayoutConstraint.activate([
            locationImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            locationImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            locationImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            locationImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            
            locationLabel.leadingAnchor.constraint(equalTo: locationImageView.leadingAnchor, constant: 8),
            locationLabel.bottomAnchor.constraint(equalTo: locationImageView.bottomAnchor, constant: -8)
        ])
    }
    
    func configureImageView() {
        locationImageView.translatesAutoresizingMaskIntoConstraints = false
        locationImageView.layer.cornerRadius = 8
        locationImageView.layer.masksToBounds = true
    }
    
    func configureLabel() {
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.textColor = .white
        locationLabel.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
    }
    
    func set(for location: LocationModel) {
        locationLabel.text = location.name
        locationImageView.downloadImage(from: location.image)
    }
}
