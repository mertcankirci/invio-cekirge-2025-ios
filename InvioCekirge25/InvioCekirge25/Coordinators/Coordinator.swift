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

protocol ParentCoordinator: Coordinator {
    var childCoordinators: [Coordinator] { get set }
    
    func addChild(_ child: Coordinator?)
    
    func childDidFinish(_ child: Coordinator?)
}



protocol ChildCoordinator: Coordinator {
    var viewControllerRef: UIViewController? {get set}
    func coordinatorDidFinish()
    
}
