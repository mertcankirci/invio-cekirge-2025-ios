//
//  ParentCoordinator+Ext.swift
//  InvioCekirge25
//
//  Created by Mertcan Kırcı on 4.04.2025.
//

import Foundation

extension ParentCoordinator {
    func addChild(_ child: Coordinator?) {
        if let child = child {
            childCoordinators.append(child)
        }
    }
    
    func childDidFinish(_ child: Coordinator?) {
        for (index, coordinator) in childCoordinators.enumerated() {
            if coordinator === child {
                childCoordinators.remove(at: index)
                break
            }
        }
    }
}
