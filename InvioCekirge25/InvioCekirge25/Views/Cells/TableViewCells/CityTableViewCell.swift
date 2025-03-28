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
    let navigationButton = UIButton()
    let container = UIView()
    weak var delegate: CityTableViewCellDelegate?
    private var city: CityModel?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureLabels()
        configureButton()
        configureContainer()
        
        configureCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cityLabel.text = nil
    }
    
    func configureLabels() {
        cityLabel.translatesAutoresizingMaskIntoConstraints = false
        cityLabel.font = .systemFont(ofSize: 18, weight: .bold)
    }
    
    func configureButton() {
        navigationButton.translatesAutoresizingMaskIntoConstraints = false
        navigationButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        navigationButton.addTarget(self, action: #selector(didTapNavigationButton), for: .touchUpInside)
    }
    
    func configureContainer() {
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .secondarySystemBackground
        container.layer.cornerRadius = 8
        container.layer.masksToBounds = true 
        
        container.addSubview(cityLabel)
        container.addSubview(navigationButton)
    }
    
    func configureCell() {
        selectionStyle = .none
        contentView.addSubview(container)
        
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            cityLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            cityLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            cityLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12),
            
            navigationButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            navigationButton.centerYAnchor.constraint(equalTo: cityLabel.centerYAnchor),
            navigationButton.widthAnchor.constraint(equalToConstant: 16),
            navigationButton.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
    
    func set(city: CityModel) {
        cityLabel.text = city.city
        self.city = city
    }
    
}

extension CityTableViewCell {
    @objc func didTapNavigationButton() {
        guard let city = city else { return }
        delegate?.didTapNavigationButton(from: city)
    }
}
