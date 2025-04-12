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
    private let persistenceService: PersistenceServiceProtocol
    
    init(navigationController: UINavigationController, location: LocationModel, cityName: String, persistenceService: PersistenceServiceProtocol) {
        self.navigationController = navigationController
        self.location = location
        self.cityName = cityName
        self.persistenceService = persistenceService
    }
    
    func start(animated: Bool) {
        let locationDetailVC = LocationDetailViewController(persistenceService: persistenceService)
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
        parent?.navigateToMapDetailScreen(animated: true, title: title, locations: locationArray, isFromLocationDetailVC: true)
    }
}
