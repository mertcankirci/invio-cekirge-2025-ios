//
//  FavouritesCoordinator.swift
//  InvioCekirge25
//
//  Created by Mertcan Kırcı on 27.03.2025.
//

import UIKit

class FavouritesCoordinator: ChildCoordinator {
    
    var viewControllerRef: UIViewController?
    var parent: RootCoordinator?
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start(animated: Bool) {
        let favouritesVC = FavouritesViewController()
        viewControllerRef = favouritesVC
        favouritesVC.coordinator = self
        navigationController.pushViewController(favouritesVC, animated: animated)
    }
    
    func coordinatorDidFinish() {
        parent?.childDidFinish(self)
    }
    
    func navigateToLocationDetailScreen(with location: LocationModel) {
        let title = location.locationsCity ?? ""
        parent?.navigateToLocationDetailScreen(animated: true, location: location, cityName: title)
    }
}
