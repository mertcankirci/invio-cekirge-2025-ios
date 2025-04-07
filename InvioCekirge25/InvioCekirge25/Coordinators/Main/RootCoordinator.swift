//
//  RootCoordinator.swift
//  InvioCekirge25
//
//  Created by Mertcan Kırcı on 27.03.2025.
//

import UIKit

final class RootCoordinator: Coordinator, ParentCoordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var mainViewController: MainViewController?
    private var cities: [CityModel]?
    private var totalPage: Int?
    
    init(navigationController: UINavigationController, cities: [CityModel]?, totalPage: Int?) {
        self.navigationController = navigationController
        self.cities = cities
        self.totalPage = totalPage
    }
    
    func start(animated: Bool) {
        mainViewController = MainViewController()
        mainViewController!.coordinator = self
        mainViewController!.cities = cities
        mainViewController!.totalPage = totalPage
        navigationController.setViewControllers([mainViewController!], animated: animated)
    }
}

extension RootCoordinator {
    func navigateToFavouritesScreen(animated: Bool) {
        let favouritesCoordinator = FavouritesCoordinator(navigationController: navigationController)
        favouritesCoordinator.parent = self
        addChild(favouritesCoordinator)
        favouritesCoordinator.start(animated: animated)
        
        if let vc = favouritesCoordinator.viewControllerRef as? FavouritesViewController {
            vc.delegate = mainViewController
        }
    }
    
    func navigateToMapDetailScreen(animated: Bool, title: String, locations: [LocationModel], isFromLocationDetailVC: Bool = false) {
        let mapCoordinator = MapCoordinator(navigationController: navigationController, title: title, locations: locations, isFromLocationDetailVC: isFromLocationDetailVC)
        mapCoordinator.parent = self
        addChild(mapCoordinator)
        mapCoordinator.start(animated: animated)
    }
    
    func navigateToLocationDetailScreen(animated: Bool, location: LocationModel, cityName: String) {
        let locationDetailCoordinator = LocationDetailCoordinator(navigationController: navigationController, location: location, cityName: cityName)
        locationDetailCoordinator.parent = self
        addChild(locationDetailCoordinator)
        locationDetailCoordinator.start(animated: animated)
        
        if let vc = locationDetailCoordinator.viewControllerRef as? LocationDetailViewController {
            vc.delegate = mainViewController
        }
    }
}
