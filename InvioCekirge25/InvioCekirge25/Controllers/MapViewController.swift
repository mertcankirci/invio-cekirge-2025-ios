//
//  MapViewController.swift
//  InvioCekirge25
//
//  Created by Mertcan Kırcı on 28.03.2025.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    var locations: [LocationModel]?

    weak var coordinator: MapCoordinator?
    let mapView = MKMapView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureVC()
        configureMapView()
        
        configureUI()
        
        addPin()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        coordinator?.coordinatorDidFinish()
    }
    
    
    func configureMapView() {
        mapView.delegate = self
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        if let firstLocation = locations?.first {
            let lat = firstLocation.coordinates.lat
            let lon = firstLocation.coordinates.lng
            
            let center = CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lon))
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: center, span: span)

            mapView.setRegion(region, animated: false)
        }
    }
    
    func configureVC() {
        view.backgroundColor = .systemGroupedBackground
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    func configureUI() {
        view.addSubview(mapView)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }


}

///MapView Delegate extension
extension MapViewController: MKMapViewDelegate {
    
}

///Custom functions extension

extension MapViewController {
    func addPin() {
        guard let locations = locations, locations.count > 0 else { Log.warning("No locations found on Map VC"); return }
        
        
        for location in locations {
            let annotation = MKPointAnnotation()
            annotation.title = location.name
            annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(location.coordinates.lat), longitude: CLLocationDegrees(location.coordinates.lng))
            
            mapView.addAnnotation(annotation)
        }
    }
}
