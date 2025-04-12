//
//  EmptyStateView.swift
//  InvioCekirge25
//
//  Created by Mertcan Kırcı on 7.04.2025.
//

import UIKit

class EmptyStateView: UIView {
    
    let emptyStateImageView = UIImageView()
    let emptyStateLabel = UILabel()
    let imageSize: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 260 : 200
    
    init(description: String, imageName: String, frame: CGRect) {
        super.init(frame: frame)
        self.emptyStateLabel.text = description
        self.emptyStateImageView.image = UIImage(systemName: imageName)
        
        configureView()
        configureImageView()
        configureLabel()
        configureUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        configureImageView()
        configureLabel()
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureLabel() {
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.font = .systemFont(ofSize: 22, weight: .bold)
        emptyStateLabel.textColor = .secondaryLabel
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.preferredMaxLayoutWidth = 400
    }
    
    func configureImageView() {
        emptyStateImageView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateImageView.tintColor = .accent
        emptyStateImageView.contentMode = .scaleAspectFit
    }
    
    func configureUI() {
        [emptyStateImageView, emptyStateLabel].forEach({ addSubview($0) })
        
        let imageMultiplier: CGFloat = 0.7
        
        NSLayoutConstraint.activate([
            emptyStateImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            emptyStateImageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -40),
            emptyStateImageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: imageMultiplier),
            emptyStateImageView.heightAnchor.constraint(equalTo: emptyStateImageView.widthAnchor),
            
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 24),
            emptyStateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 32),
            emptyStateLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -32),
            emptyStateLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])
    }

    func configureView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
    }
}
