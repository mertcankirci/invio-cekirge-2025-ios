//
//  LocationTableViewCell.swift
//  InvioCekirge25
//
//  Created by Mertcan Kırcı on 27.03.2025.
//

import UIKit

protocol LocationTableViewCellDelegate: AnyObject {
    func errorOccured(with errorMessage: String)
    func removedFavorite(_ fav: LocationModel)
}

class LocationTableViewCell: UITableViewCell {
    
    static let reuseId = "LocationTableViewCell"
    private let locationLabel = UILabel()
    private let mainContainer = UIView()
    private let seperator = UIView()
    private let favButton = UIButton()
    
    var persistenceService: PersistenceServiceProtocol?
    
    private var isFavorite: Bool = false
    
    weak var delegate: LocationTableViewCellDelegate?
    var location: LocationModel?
    
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
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        UIView.animate(withDuration: 0.25) {
            self.mainContainer.backgroundColor = highlighted ? UIColor.systemGray5 : UIColor.secondarySystemGroupedBackground
        }
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
        locationLabel.lineBreakMode = .byTruncatingTail
    }
    
    func configureContainer() {
        mainContainer.translatesAutoresizingMaskIntoConstraints = false
        mainContainer.backgroundColor = InvioColors.secondaryGroupedBackground
        
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
            locationLabel.trailingAnchor.constraint(equalTo: favButton.leadingAnchor, constant: -8),
            
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
    
    func set(location: LocationModel, isFavorite: Bool, persistenceService: PersistenceServiceProtocol) {
        self.persistenceService = persistenceService
        self.location = location
        self.isFavorite = isFavorite
        locationLabel.text = location.name
        
        let symbolName = isFavorite ? "heart.fill" : "heart"
        favButton.setImage(UIImage(systemName: symbolName), for: .normal)
    }
    
    ///Trigger this methods on parent for better UI/UX
    func ifLastCellPerform() {
        UIView.animate(withDuration: 0.25) {
            self.mainContainer.layer.cornerRadius = 12
            self.mainContainer.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        seperator.isHidden = true
    }
    
    /// If its the first cell (at the very top) adjusts corner radius
    func ifFirstCellPerform() {
        UIView.animate(withDuration: 0.25) {
            self.mainContainer.layer.cornerRadius = 12
            self.mainContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
    }
    
    /// If its the only cell adjusts corner radius
    func ifOnlyCellPerform() {
        UIView.animate(withDuration: 0.25) {
            self.mainContainer.layer.cornerRadius = 12
            self.mainContainer.layer.maskedCorners = [
                .layerMinXMinYCorner,
                .layerMaxXMinYCorner,
                .layerMinXMaxYCorner,
                .layerMaxXMaxYCorner
            ]
        }
        seperator.isHidden = true
    }
}

extension LocationTableViewCell {
    @objc
    func didTapFavButton() {
        guard let location = location else { return }
        
        do {
            if isFavorite {
                
                try persistenceService?.deleteFavLocation(for: location)
                isFavorite = false
                delegate?.removedFavorite(location)
            } else {
                try persistenceService?.saveFavLocation(for: location)
                isFavorite = true
            }
        } catch {
            delegate?.errorOccured(with: error.localizedDescription)
        }
        
        UIView.transition(with: favButton, duration: 0.4) { [weak self] in
            guard let self = self else { return }
            let symbolName = self.isFavorite ? "heart.fill" : "heart"
            self.favButton.setImage(UIImage(systemName: symbolName), for: .normal)
            self.animateFavButton()
        }
        
        UIHelper.successHapticFeedback()
    }
    
    private func animateFavButton() {
        UIView.animate(withDuration: 0.1, animations: {
            self.favButton.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.favButton.transform = CGAffineTransform.identity
            }
        })
    }
}
