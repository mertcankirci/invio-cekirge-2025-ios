//
//  LocationTableViewCell.swift
//  InvioCekirge25
//
//  Created by Mertcan Kırcı on 27.03.2025.
//

import UIKit

class LocationTableViewCell: UITableViewCell {
    
    static let reuseId = "LocationTableViewCell"
    let locationLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureLabel()
        configureCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureLabel() {
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configureCell() {
        addSubview(locationLabel)
        
        NSLayoutConstraint.activate([
            locationLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            locationLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    
    func set(location: LocationModel) {
        locationLabel.text = location.name
    }
}
