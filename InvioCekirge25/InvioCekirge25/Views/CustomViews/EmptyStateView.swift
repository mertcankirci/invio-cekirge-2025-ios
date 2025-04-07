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
    }
    
    func configureImageView() {
        emptyStateImageView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateImageView.tintColor = .accent
        emptyStateImageView.contentMode = .scaleAspectFill
    }
    
    func configureUI() {
        [emptyStateImageView, emptyStateLabel].forEach({ addSubview($0) })
        
        NSLayoutConstraint.activate([
            emptyStateImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            emptyStateImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            emptyStateImageView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 200),
            
            emptyStateLabel.leadingAnchor.constraint(equalTo: emptyStateImageView.leadingAnchor),
            emptyStateLabel.trailingAnchor.constraint(equalTo: emptyStateImageView.trailingAnchor),
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 64),
        ])
    }
    
    func configureView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
    }
}
