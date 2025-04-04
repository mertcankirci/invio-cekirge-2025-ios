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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradientOnce()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupGradientOnce() {
        gradientView.frame = bounds
        gradientView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        gradientView.isUserInteractionEnabled = false

        gradientLayer.colors = [
            UIColor.black.cgColor,
            UIColor.clear.cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.frame = gradientView.bounds

        gradientView.layer.addSublayer(gradientLayer)
        addSubview(gradientView)
        gradientView.isHidden = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientView.frame = bounds
        gradientLayer.frame = gradientView.bounds
    }

    override func downloadImage(from urlString: String?, completion: ((Bool) -> Void)? = nil) {
        super.downloadImage(from: urlString) { [weak self] success in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.gradientView.isHidden = !success
                completion?(success)
            }
        }
    }

    override func resetImage() {
        super.resetImage()
        gradientView.isHidden = true
    }
}
