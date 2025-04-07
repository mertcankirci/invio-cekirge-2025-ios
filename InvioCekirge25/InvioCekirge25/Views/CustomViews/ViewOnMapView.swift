//
//  ViewOnMapView.swift
//  InvioCekirge25
//
//  Created by Mertcan Kırcı on 7.04.2025.
//

import UIKit

protocol ViewOnMapViewDelegate: AnyObject {
    func viewOnMapButtonTapped()
}

class ViewOnMapView: UIView {
    
    weak var delegate: ViewOnMapViewDelegate?
    
    private let viewOnMapContainer = UIView()
    private let viewOnMapButton = UIButton()
    private let viewOnMapCallerLabel = UILabel()
    private let viewOnMapActionLabel = UILabel()
    private let viewOnMapImage = UIImageView()
    private let viewOnMapImageContainer = UIView() /// Container to hold viewOnMapImage
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    
    init(frame: CGRect, imageName: String, actionDescription: String, callerDescription: String) {
        super.init(frame: frame)
        viewOnMapImage.image = UIImage(systemName: imageName)
        viewOnMapCallerLabel.text = callerDescription
        viewOnMapActionLabel.text = actionDescription
        
        configureView()
        configureLabels()
        configureImages()
        configureButtons()
        configureContainers()
        
        configureUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        configureView()
        configureLabels()
        configureImages()
        configureButtons()
        configureContainers()
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureLabels() {
        [viewOnMapCallerLabel, viewOnMapActionLabel].forEach({ $0.translatesAutoresizingMaskIntoConstraints = false })
        
        viewOnMapCallerLabel.textColor = InvioColors.titleLabelColor
        viewOnMapCallerLabel.font = .systemFont(ofSize: 14, weight: .regular)
        
        viewOnMapActionLabel.textColor = InvioColors.secondaryLabelColor
        viewOnMapActionLabel.font = .systemFont(ofSize: 12, weight: .light)
    }
    
    func configureImages() {
        viewOnMapImage.translatesAutoresizingMaskIntoConstraints = false
        viewOnMapImage.tintColor = .accent
        viewOnMapImage.contentMode = .scaleAspectFit
        viewOnMapImage.isUserInteractionEnabled = false
    }
    
    func configureButtons() {
        viewOnMapButton.translatesAutoresizingMaskIntoConstraints = false
        viewOnMapButton.setTitle("Keşfet", for: .normal)
        viewOnMapButton.layer.cornerRadius = 15
        viewOnMapButton.layer.masksToBounds = true
        viewOnMapButton.backgroundColor = .white.withAlphaComponent(0.3)
        viewOnMapButton.titleLabel?.textColor = .white
        viewOnMapButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        viewOnMapButton.addTarget(self, action: #selector(viewOnMapButtonTapped), for: .touchUpInside)
    }
    
    func configureContainers() {
        viewOnMapContainer.translatesAutoresizingMaskIntoConstraints = false
        
        viewOnMapImageContainer.translatesAutoresizingMaskIntoConstraints = false
        viewOnMapImageContainer.layer.cornerRadius = 8
        viewOnMapImageContainer.layer.masksToBounds = true
        viewOnMapImageContainer.backgroundColor = .gray.withAlphaComponent(0.8)
    }
    
    func configureUI() {
        
        [viewOnMapContainer, viewOnMapImageContainer, viewOnMapActionLabel, viewOnMapCallerLabel, viewOnMapButton, viewOnMapImage].forEach { component in
            self.addSubview(component)
        }
        
        NSLayoutConstraint.activate([
            viewOnMapContainer.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            viewOnMapContainer.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            viewOnMapContainer.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            viewOnMapContainer.topAnchor.constraint(equalTo: self.topAnchor),
            
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
    }
    
    func configureView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
    }
}

extension ViewOnMapView {
    @objc
    func viewOnMapButtonTapped() {
        delegate?.viewOnMapButtonTapped()
    }
    
    private func addBlurEffectToViewOnMapContainer() {
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
}
