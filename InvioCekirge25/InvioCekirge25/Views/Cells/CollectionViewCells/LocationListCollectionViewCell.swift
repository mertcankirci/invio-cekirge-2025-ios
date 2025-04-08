//
//  LocationListCollectionViewCell.swift
//  InvioCekirge25
//
//  Created by Mertcan Kırcı on 28.03.2025.
//

import UIKit

protocol LocationListCollectionViewCellDelegate: AnyObject {
    func didTapDetailButton(location: LocationModel)
}

class LocationListCollectionViewCell: UICollectionViewCell {
    static let reuseId = "LocationListCollectionViewCell"
    
    let locationImageView = CekirgeGradientImageView(frame: .zero)
    let locationLabel = UILabel()
    let distanceLabel = UILabel()
    let detailButton = UIButton()
    
    weak var delegate: LocationListCollectionViewCellDelegate?
    
    var location: LocationModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCell()
        configureLabel()
        configureImageView()
        configureButton()
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell() {
        contentView.backgroundColor = .clear
    }
    
    func configureButton() {
        detailButton.translatesAutoresizingMaskIntoConstraints = false
        detailButton.setImage(InvioImages.detail?.withSymbolSize(22), for: .normal)
        detailButton.imageView?.contentMode = .scaleAspectFit
        detailButton.backgroundColor = .gray.withAlphaComponent(0.7)
        detailButton.layer.cornerRadius = 22
        detailButton.layer.masksToBounds = true
        detailButton.addTarget(self, action: #selector(didTapDetailButton), for: .touchUpInside)
    }
    
    func configureImageView() {
        locationImageView.translatesAutoresizingMaskIntoConstraints = false
        locationImageView.layer.cornerRadius = 8
        locationImageView.layer.masksToBounds = true
    }
    
    func configureLabel() {
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.textColor = InvioColors.titleLabelColor
        locationLabel.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        distanceLabel.textColor = InvioColors.secondaryLabelColor
        distanceLabel.font = UIFont.systemFont(ofSize: 16, weight: .light)
    }
    
    func configureUI() {
        [locationImageView, locationLabel, detailButton, distanceLabel].forEach({ contentView.addSubview($0) })
        
        NSLayoutConstraint.activate([
            locationImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            locationImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            locationImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            locationImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            
            locationLabel.leadingAnchor.constraint(equalTo: locationImageView.leadingAnchor, constant: 16),
            locationLabel.bottomAnchor.constraint(equalTo: locationImageView.bottomAnchor, constant: -16),
            locationLabel.trailingAnchor.constraint(equalTo: detailButton.leadingAnchor, constant: -16),
            
            distanceLabel.bottomAnchor.constraint(equalTo: locationLabel.topAnchor, constant: -4),
            distanceLabel.leadingAnchor.constraint(equalTo: locationLabel.leadingAnchor),
            distanceLabel.trailingAnchor.constraint(equalTo: locationLabel.trailingAnchor),
            
            detailButton.centerYAnchor.constraint(equalTo: locationImageView.centerYAnchor),
            detailButton.trailingAnchor.constraint(equalTo: locationImageView.trailingAnchor, constant: -16),
            detailButton.heightAnchor.constraint(equalToConstant: 44),
            detailButton.widthAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    func set(for location: LocationModel) {
        self.location = location
        locationLabel.text = location.name
        locationImageView.downloadImage(from: location.image)
        
        if let distance = location.distanceFromUser {
            distanceLabel.text = UIHelper.calculateDistanceLabelText(distance: distance)
        }
    }
    
    @objc
    func didTapDetailButton() {
        guard let location = location else { return }
        delegate?.didTapDetailButton(location: location)
    }
}
