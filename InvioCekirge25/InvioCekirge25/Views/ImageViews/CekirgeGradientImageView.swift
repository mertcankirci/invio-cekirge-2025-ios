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
    private var needsAlpha: Bool = false ///in dark mode city table view cells aren't visible. We'll modify their gradient color this way.
    private let placeholderView = UIView()
    private let placeholderSymbol = UIImageView()
    
    init(frame: CGRect, needsAlpha: Bool = false) {
        self.needsAlpha = needsAlpha
        super.init(frame: frame)
        setupGradientOnce()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradientOnce()
        setupPlaceholder()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPlaceholder() {
        placeholderView.backgroundColor = .black
        placeholderSymbol.image = UIImage(systemName: "photo")
        placeholderSymbol.tintColor = .gray
        placeholderSymbol.contentMode = .scaleAspectFit
        
        placeholderView.translatesAutoresizingMaskIntoConstraints = false
        placeholderSymbol.translatesAutoresizingMaskIntoConstraints = false
        
        placeholderView.addSubview(placeholderSymbol)
        self.addSubview(placeholderView)
        
        NSLayoutConstraint.activate([
            placeholderView.topAnchor.constraint(equalTo: self.topAnchor),
            placeholderView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            placeholderView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            placeholderView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            placeholderSymbol.centerXAnchor.constraint(equalTo: placeholderView.centerXAnchor),
            placeholderSymbol.centerYAnchor.constraint(equalTo: placeholderView.centerYAnchor),
            placeholderSymbol.widthAnchor.constraint(equalToConstant: 60),
            placeholderSymbol.heightAnchor.constraint(equalToConstant: 60)
        ])
        placeholderView.isHidden = true
    }

    private func setupGradientOnce() {
        gradientView.frame = bounds
        gradientView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        gradientView.isUserInteractionEnabled = false

        gradientLayer.colors = [
            UIColor.black.withAlphaComponent(needsAlpha ? 0.8 : 1.0).cgColor,
            UIColor.clear.cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.frame = gradientView.bounds

        gradientView.layer.addSublayer(gradientLayer)
        addSubview(gradientView)
        gradientView.isHidden = false
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientView.frame = bounds
        gradientLayer.frame = gradientView.bounds
    }

    override func downloadImage(from urlString: String?, completion: ((Bool) -> Void)? = nil) {
        
        placeholderView.isHidden = true
        
        super.downloadImage(from: urlString) { [weak self] success in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.gradientView.isHidden = !success
                self.placeholderView.isHidden = success
                completion?(success)
            }
        }
    }

    override func resetImage() {
        super.resetImage()
        gradientView.isHidden = true
    }
}
