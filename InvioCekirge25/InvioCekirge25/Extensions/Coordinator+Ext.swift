//
//  Coordinator+Ext.swift
//  InvioCekirge25
//
//  Created by Mertcan Kırcı on 4.04.2025.
//

import Foundation

extension Coordinator {
    func popViewController(animated: Bool) {
        navigationController.popViewController(animated: true)
    }
    
    func popToViewController(ofClass: AnyClass, animated: Bool) {
        navigationController.popToViewController(ofClass: ofClass, animated: animated)
    }
}
