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
    var cityName: String
    
    init(navigationController: UINavigationController, location: LocationModel, cityName: String) {
        self.navigationController = navigationController
        self.location = location
        self.cityName = cityName
    }
    
    func start(animated: Bool) {
        let locationDetailVC = LocationDetailViewController()
        viewControllerRef = locationDetailVC
        locationDetailVC.coordinator = self
        locationDetailVC.location = location
        locationDetailVC.cityNameLabel.text = cityName.uppercased()
        navigationController.pushViewController(locationDetailVC, animated: animated)
    }
    
    func coordinatorDidFinish() {
        parent?.childDidFinish(self)
    }
}

extension LocationDetailCoordinator {
    func navigateToMapDetail(_ location: LocationModel) {
        let title = location.name
        let locationArray: [LocationModel] = [location]
        parent?.navigateToMapDetailScreen(animated: true, title: title, locations: locationArray)
    }
}
