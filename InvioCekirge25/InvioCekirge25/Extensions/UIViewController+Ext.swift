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
    
    func showToast(message : String) {
        let toastLabel = UILabel(frame: .zero)
        
        if let existingToast = view.viewWithTag(999) {
            existingToast.removeFromSuperview()
        }
        
        toastLabel.tag = 999
        
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        toastLabel.backgroundColor = .systemFill
        toastLabel.textColor = .accent
        toastLabel.font = .systemFont(ofSize: 16, weight: .medium)
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.numberOfLines = 0
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        
        self.view.addSubview(toastLabel)
        
        NSLayoutConstraint.activate([
            toastLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toastLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            toastLabel.widthAnchor.constraint(equalToConstant: 300),
            toastLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        UIView.animate(withDuration: 3.0, delay: 0.1, options: .curveEaseOut, animations: {
             toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    var topbarHeight: CGFloat {
        return (view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0.0) +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
    }
}
