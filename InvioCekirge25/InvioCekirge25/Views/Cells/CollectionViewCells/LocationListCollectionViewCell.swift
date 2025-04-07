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
    let detailButton = UIButton()
    
    weak var delegate: LocationListCollectionViewCellDelegate?
    
    var location: LocationModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLabel()
        configureImageView()
        configureButton()
        
        configureCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell() {
        contentView.backgroundColor = .clear
        
        contentView.addSubview(locationImageView)
        contentView.addSubview(locationLabel)
        contentView.addSubview(detailButton)
        
        NSLayoutConstraint.activate([
            locationImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            locationImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            locationImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            locationImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            
            locationLabel.leadingAnchor.constraint(equalTo: locationImageView.leadingAnchor, constant: 16),
            locationLabel.centerYAnchor.constraint(equalTo: locationImageView.centerYAnchor),
            
            detailButton.centerYAnchor.constraint(equalTo: locationImageView.centerYAnchor),
            detailButton.trailingAnchor.constraint(equalTo: locationImageView.trailingAnchor, constant: -16),
            detailButton.heightAnchor.constraint(equalToConstant: 44),
            detailButton.widthAnchor.constraint(equalToConstant: 44)
        ])
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
    }
    
    func set(for location: LocationModel) {
        self.location = location
        locationLabel.text = location.name
        locationImageView.downloadImage(from: location.image)
    }
    
    @objc
    func didTapDetailButton() {
        guard let location = location else { return }
        delegate?.didTapDetailButton(location: location)
    }
}
