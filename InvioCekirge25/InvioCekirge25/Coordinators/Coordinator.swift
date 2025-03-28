//
//  Coordinator.swift
//  InvioCekirge25
//
//  Created by Mertcan Kırcı on 27.03.2025.
//

import UIKit

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get set }
    
    func start(animated: Bool)
    
    func popViewController(animated: Bool)
}

extension Coordinator {
    func popViewController(animated: Bool) {
        navigationController.popViewController(animated: true)
    }
    
    func popToViewController(ofClass: AnyClass, animated: Bool) {
        navigationController.popToViewController(ofClass: ofClass, animated: animated)
    }
}

protocol ParentCoordinator: Coordinator {
    var childCoordinators: [Coordinator] { get set }
    
    func addChild(_ child: Coordinator?)
    
    func childDidFinish(_ child: Coordinator?)
}

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

protocol ChildCoordinator: Coordinator {
    var viewControllerRef: UIViewController? {get set}
    func coordinatorDidFinish()
    
}
