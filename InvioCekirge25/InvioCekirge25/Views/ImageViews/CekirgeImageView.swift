//
//  CekirgeImageView.swift
//  InvioCekirge25
//
//  Created by Mertcan Kırcı on 28.03.2025.
//

import UIKit
import Kingfisher

class CekirgeImageView: UIImageView {
    var currentURLString: String?

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.clipsToBounds = true
        self.contentMode = .scaleAspectFill
        self.backgroundColor = .black
    }

    func downloadImage(from urlString: String?, completion: ((Bool) -> Void)? = nil) {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            Log.warning("Couldn't download image. Something wrong with the url.")
            self.image = nil
            completion?(false)
            return
        }

        currentURLString = urlString
        let placeholderImage = UIImage().withTintColor(.systemFill, renderingMode: .alwaysTemplate)
        let processor = DownsamplingImageProcessor(size: self.bounds.size)

        self.kf.setImage(
            with: url,
            placeholder: placeholderImage,
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(0.3)),
                .cacheOriginalImage,
            ]
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let value):
                if self.currentURLString == urlString {
                    DispatchQueue.main.async {
                        self.image = value.image
                        completion?(true)
                    }
                }
            case .failure:
                Log.error("Error in downloading image.")
                DispatchQueue.main.async {
                    self.image = nil
                    completion?(false)
                }
            }
        }
    }

    func resetImage() {
        self.image = nil
        self.currentURLString = nil
        self.kf.cancelDownloadTask()
    }
}
