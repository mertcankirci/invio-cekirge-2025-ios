//
//  CekirgeImageView.swift
//  InvioCekirge25
//
//  Created by Mertcan Kırcı on 28.03.2025.
//

import UIKit
import Kingfisher
import SwiftUICore

class CekirgeImageView: UIImageView {
    @Environment(\.colorScheme) var colorScheme
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
        self.backgroundColor = .systemGray
    }
    
    func downloadImage(from urlString: String?) {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            Log.warning("Couldn't download image. Something wrong with the url.")
            return
        }

        currentURLString = urlString
        
        let placeHolderImage = UIImage()

        self.kf.setImage(with: url, placeholder: placeHolderImage, options: [.transition(.fade(0.3))], completionHandler: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let value):
                if self.currentURLString == urlString {
                    Log.success("Downloaded image successfully.")
                    self.image = value.image
                }
            case .failure:
                Log.error("Error in downloading image.")
            }
        })
    }
}
