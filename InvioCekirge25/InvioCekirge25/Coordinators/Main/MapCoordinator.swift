//
//  MapCoordinator.swift
//  InvioCekirge25
//
//  Created by Mertcan Kırcı on 28.03.2025.
//

import UIKit

class MapCoordinator: ChildCoordinator {
    var viewControllerRef: UIViewController?
    var parent: RootCoordinator?
    var navigationController: UINavigationController
    private var title: String?
    private var locations: [LocationModel]
    
    init(navigationController: UINavigationController, title: String, locations: [LocationModel]) {
        self.navigationController = navigationController
        self.title = title
        self.locations = locations
    }
    
    func start(animated: Bool) {
        let mapVC = MapViewController()
        viewControllerRef = mapVC
        mapVC.coordinator = self
        mapVC.title = title
        mapVC.locations = locations
        navigationController.pushViewController(mapVC, animated: animated)
        
        Log.success("Favourites coordinator initialized.")
    }
    
    func coordinatorDidFinish() {
        parent?.childDidFinish(self)
    }
}
