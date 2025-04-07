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
    private var isFromLocationDetailVC: Bool
    
    init(navigationController: UINavigationController, title: String, locations: [LocationModel], isFromLocationDetailVC: Bool = false) {
        self.navigationController = navigationController
        self.title = title
        self.locations = locations
        self.isFromLocationDetailVC = isFromLocationDetailVC
    }
    
    func start(animated: Bool) {
        let mapVC = MapViewController()
        viewControllerRef = mapVC
        mapVC.coordinator = self
        mapVC.title = title
        mapVC.locations = locations
        mapVC.isFromDetailVC = isFromLocationDetailVC
        navigationController.pushViewController(mapVC, animated: animated)
    }
    
    func coordinatorDidFinish() {
        parent?.childDidFinish(self)
    }
    
    func navigateToLocationDetail(location: LocationModel, cityName: String) {
        parent?.navigateToLocationDetailScreen(animated: true, location: location, cityName: cityName)
    }
}
