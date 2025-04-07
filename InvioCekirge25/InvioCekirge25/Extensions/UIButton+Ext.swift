//
//  UIButton+Ext.swift
//  InvioCekirge25
//
//  Created by Mertcan Kırcı on 7.04.2025.
//

import UIKit

extension UIImage {
    /// For sizing SF Symbols
    func withSymbolSize(_ pointSize: CGFloat, weight: UIImage.SymbolWeight = .regular) -> UIImage? {
        let config = UIImage.SymbolConfiguration(pointSize: pointSize, weight: weight)
        return self.withConfiguration(config)
    }
}
