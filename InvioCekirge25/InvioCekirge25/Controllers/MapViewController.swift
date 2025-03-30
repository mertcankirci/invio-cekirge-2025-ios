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
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: AppLayouts.shared.snapToCenterLocationListLayout())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureVC()
        configureMapView()
        configureCollectionView()
        
        configureUI()
        addPin()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        coordinator?.coordinatorDidFinish()
    }
    
    
    func configureUI() {
        view.addSubview(mapView)
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            collectionView.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -32),
            collectionView.leadingAnchor.constraint(equalTo: mapView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: mapView.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 120)
        ])
    }
    
    func configureVC() {
        view.backgroundColor = .systemGroupedBackground
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    func configureMapView() {
        mapView.delegate = self
        mapView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configureCollectionView() {
        collectionView.bounces = false
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        collectionView.register(LocationListCollectionViewCell.self, forCellWithReuseIdentifier: LocationListCollectionViewCell.reuseId)
        
    }
}

///MapView Delegate extension
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let selectedAnnotation = view.annotation else { return }

        for annotation in mapView.annotations {
            if let annotationView = mapView.view(for: annotation) as? MKMarkerAnnotationView,
               annotation !== selectedAnnotation {
                DispatchQueue.main.async {
                    annotationView.markerTintColor = .systemRed
                    annotationView.glyphText = nil
                }
            }
        }

        if let selectedView = mapView.view(for: selectedAnnotation) as? MKMarkerAnnotationView {
            let name = selectedAnnotation.title
            let index = (locations?.firstIndex(where: { $0.name == name })) ?? 0 ///fallback to 0 to ensure there isn't any crashes
            let indexPath = IndexPath(row: index, section: 0)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                selectedView.markerTintColor = .accent
                selectedView.glyphText = "★"
                
                self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true) ///scroll to collection view item when annotation changes
            }
        }
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        guard let annotation = mapView.annotations.first(where: { $0.title == locations?.first?.name }), mapView.selectedAnnotations.isEmpty else { return }

        mapView.selectAnnotation(annotation, animated: true)
        
        if let annotationView = mapView.view(for: annotation) {
            self.mapView(mapView, didSelect: annotationView)
        }
    }
}

///CollectionView Delegate extension
extension MapViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let locations = locations else { return 0 }
        return locations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LocationListCollectionViewCell.reuseId, for: indexPath) as? LocationListCollectionViewCell,
              let location = locations?[indexPath.row] else { return UICollectionViewCell() }
        cell.set(for: location)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let location = locations?[indexPath.item],
              let annotation = mapView.annotations.first(where: { $0.title == location.name }) else {
            Log.warning("Couldn't find location on select")
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.mapView.selectAnnotation(annotation, animated: true)
            self.setRegionForAnnotation(for: annotation)
        }
        
    }
}

///Custom functions extension
extension MapViewController {
    private func addPin() {
        guard let locations = locations, locations.count > 0 else { Log.warning("No locations found on Map VC"); return }
        
        var annotations: [MKPointAnnotation] = []

        for location in locations {
            let annotation = createAnnotation(with: location)
            annotations.append(annotation)
        }

        mapView.addAnnotations(annotations)
        mapView.showAnnotations(annotations, animated: false)
    }
    
    func createAnnotation(with location: LocationModel) -> MKPointAnnotation {
        let annotation = MKPointAnnotation()
        annotation.title = location.name
        annotation.coordinate = CLLocationCoordinate2D(
            latitude: CLLocationDegrees(location.coordinates.lat),
            longitude: CLLocationDegrees(location.coordinates.lng)
        )
        
        return annotation
    }
    
    func setRegionForAnnotation(for annotation: MKAnnotation) {
        let lat = annotation.coordinate.latitude
        let lon = annotation.coordinate.longitude
        let center = CLLocationCoordinate2D(
            latitude: lat,
            longitude: lon
        )
        
        let span = MKCoordinateSpan(
               latitudeDelta: 0.01,
               longitudeDelta: 0.01
           )
        
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: true)
    }
}

