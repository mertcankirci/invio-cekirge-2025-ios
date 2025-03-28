//
//  UIViewController+Ext.swift
//  InvioCekirge25
//
//  Created by Mertcan Kırcı on 27.03.2025.
//

import UIKit

extension UIViewController {
    func presentAlert(errorMessage: String, title: String = "Error", buttonTitle: String = "OK") {
        let alert = UIAlertController(title: title,
                                      message: errorMessage,
                                      preferredStyle: .alert)
        
        let button = UIAlertAction(title: buttonTitle, style: .default)
        alert.addAction(button)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
}
