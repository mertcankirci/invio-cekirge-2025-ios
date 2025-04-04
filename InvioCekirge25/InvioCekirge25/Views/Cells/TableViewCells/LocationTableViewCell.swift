//
//  LocationTableViewCell.swift
//  InvioCekirge25
//
//  Created by Mertcan Kırcı on 27.03.2025.
//

import UIKit

protocol LocationTableViewCellDelegate: AnyObject {
    func didTapLocationCell(for location: LocationModel)
}

class LocationTableViewCell: UITableViewCell {
    
    static let reuseId = "LocationTableViewCell"
    private let locationLabel = UILabel()
    private let mainContainer = UIView()
    private let seperator = UIView()
    private let favButton = UIButton()
    private var isFavorite: Bool = false
    
    var location: LocationModel?
    weak var delegate: LocationTableViewCellDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureLabel()
        configureContainer()
        configureButton()
        
        configureCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        mainContainer.layer.cornerRadius = 0
        mainContainer.layer.maskedCorners = []
        seperator.isHidden = false
    }
    
    func configureLabel() {
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.textColor = .label
    }
    
    func configureContainer() {
        mainContainer.translatesAutoresizingMaskIntoConstraints = false
        mainContainer.backgroundColor = .secondarySystemGroupedBackground
        
        seperator.translatesAutoresizingMaskIntoConstraints = false
        seperator.backgroundColor = .opaqueSeparator
    }
    
    func configureButton() {
        favButton.translatesAutoresizingMaskIntoConstraints = false
        favButton.setImage(UIImage(systemName: "heart"), for: .normal)
        favButton.imageView?.contentMode = .scaleAspectFit
        
        favButton.addTarget(self, action: #selector(didTapFavButton), for: .touchUpInside)
    }
    
    func configureCell() {
        backgroundColor = .clear
        selectionStyle = .none
        
        [mainContainer, locationLabel, seperator, favButton].forEach { component in
            contentView.addSubview(component)
        }
        
        NSLayoutConstraint.activate([
            mainContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            mainContainer.heightAnchor.constraint(equalToConstant: 45),
            
            locationLabel.leadingAnchor.constraint(equalTo: mainContainer.leadingAnchor, constant: 16),
            locationLabel.centerYAnchor.constraint(equalTo: mainContainer.centerYAnchor),
            
            favButton.trailingAnchor.constraint(equalTo: mainContainer.trailingAnchor, constant: -16),
            favButton.centerYAnchor.constraint(equalTo: mainContainer.centerYAnchor),
            favButton.widthAnchor.constraint(equalToConstant: 36),
            favButton.heightAnchor.constraint(equalToConstant: 36),
            
            seperator.leadingAnchor.constraint(equalTo: mainContainer.leadingAnchor, constant: 8),
            seperator.trailingAnchor.constraint(equalTo: mainContainer.trailingAnchor, constant: -8),
            seperator.bottomAnchor.constraint(equalTo: mainContainer.bottomAnchor),
            seperator.heightAnchor.constraint(equalToConstant: 1),
        ])
    }

    
    func set(location: LocationModel, isFavorite: Bool) {
        self.location = location
        self.isFavorite = isFavorite
        locationLabel.text = location.name
        
        if isFavorite {
            favButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        }
    }
    
    ///Trigger this method on mainVC for better UI/UX
    func ifLastCellPerform() {
        UIView.animate(withDuration: 0.25) {
            self.mainContainer.layer.cornerRadius = 12
            self.mainContainer.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        seperator.isHidden = true
    }
}

extension LocationTableViewCell {
    @objc
    func didTapFavButton() {
        guard let location = location else { return }
        
        if isFavorite {
            do {
                try PersistenceService.shared.deleteFavLocation(for: location)
                isFavorite = false
            } catch {
                return
            }
        } else {
            do {
                try PersistenceService.shared.saveFavLocation(for: location)
                isFavorite = true
            } catch {
                return
            }
        }

        UIView.transition(with: favButton, duration: 0.4) {
            let symbolName = self.isFavorite ? "heart.fill" : "heart"
            self.favButton.setImage(UIImage(systemName: symbolName), for: .normal)
        }
        
        delegate?.didTapLocationCell(for: location)
        UIHelper.successHapticFeedback()
    }
}
