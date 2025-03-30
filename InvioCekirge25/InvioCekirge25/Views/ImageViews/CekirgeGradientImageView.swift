//
//  CekirgeGradientImageView.swift
//  InvioCekirge25
//
//  Created by Mertcan Kırcı on 28.03.2025.
//

import UIKit

class CekirgeGradientImageView: CekirgeImageView {

    private let gradientView = UIView()
    private let gradientLayer = CAGradientLayer()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if gradientLayer.frame != gradientView.bounds {
            gradientLayer.frame = gradientView.bounds
        }
    }

    override func downloadImage(from urlString: String?, completion: ((Bool) -> Void)? = nil)  {
        super.downloadImage(from: urlString) { [weak self] success in
            guard let self = self else { return }

            if success {
                self.setupGradientIfNeeded()
            } else {
                self.removeGradient()
            }
        }
    }

    private func setupGradientIfNeeded() {
        guard gradientView.superview == nil else { return }

        addSubview(gradientView)
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            gradientView.leadingAnchor.constraint(equalTo: leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: trailingAnchor),
            gradientView.topAnchor.constraint(equalTo: topAnchor),
            gradientView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        gradientLayer.colors = [
            UIColor.black.cgColor,
            UIColor.clear.cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)

        gradientView.layer.addSublayer(gradientLayer)
        gradientView.isUserInteractionEnabled = false
    }

    private func removeGradient() {
        gradientLayer.removeFromSuperlayer()
        gradientView.removeFromSuperview()
    }
}
