//
//  LocationDetailCoordinator.swift
//  InvioCekirge25
//
//  Created by Mertcan Kırcı on 1.04.2025.
//

import UIKit

class LocationDetailCoordinator: ChildCoordinator {
    
    var viewControllerRef: UIViewController?
    var parent: RootCoordinator?
    var navigationController: UINavigationController
    var location: LocationModel
    
    init(navigationController: UINavigationController, location: LocationModel) {
        self.navigationController = navigationController
        self.location = location
    }
    
    func start(animated: Bool) {
        let locationDetailVC = LocationDetailViewController()
        viewControllerRef = locationDetailVC
        locationDetailVC.coordinator = self
        locationDetailVC.location = location
        navigationController.pushViewController(locationDetailVC, animated: animated)
        
        Log.success("Favourites coordinator initialized.")
    }
    
    func coordinatorDidFinish() {
        parent?.childDidFinish(self)
    }
}
