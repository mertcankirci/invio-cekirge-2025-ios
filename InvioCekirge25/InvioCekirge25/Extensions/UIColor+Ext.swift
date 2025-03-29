//
//  UIColor+Ext.swift
//  InvioCekirge25
//
//  Created by Mertcan Kırcı on 28.03.2025.
//

import UIKit

extension UIColor {
    static let listCellBackground: UIColor = {
        if UITraitCollection.current.userInterfaceStyle == .dark {
            return .black
        } else {
            return .systemBackground
        }
    }()
    
    static let listCellForeground: UIColor = {
        if UITraitCollection.current.userInterfaceStyle == .dark {
            return .white
        } else {
            return .black
        }
    }()
}

