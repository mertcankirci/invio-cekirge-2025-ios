//
//  MapViewController.swift
//  InvioCekirge25
//
//  Created by Mertcan Kırcı on 28.03.2025.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    var locations: [LocationModel]?

    weak var coordinator: MapCoordinator?
    let mapView = MKMapView()
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: AppLayouts.shared.snapToCenterLocationListLayout())
    let alertController = UIAlertController(title: "Alert", message: "Konumunu haritada görmek ister misin?", preferredStyle: .alert)
    private let userLocationButton = UIButton()
    private var userLocation: CLLocation?
    
    //MARK: - Services
    private let authorizationService = AuthorizationService()
    private let locationAuthService = LocationAuthorizationService()
    private let locationService = LocationService()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureVC()
        configureMapView()
        configureCollectionView()
        configureAlertController()
        configureButtons()
        
        configureUI()
        addPin()
        
        handleLocationAuthorization()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        coordinator?.coordinatorDidFinish()
    }
    
    func configureUI() {
        [mapView, collectionView, userLocationButton].forEach { component in
            view.addSubview(component)
        }
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            collectionView.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -32),
            collectionView.leadingAnchor.constraint(equalTo: mapView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: mapView.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 120),
            
            userLocationButton.bottomAnchor.constraint(equalTo: collectionView.topAnchor, constant: -16),
            userLocationButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -16),
            userLocationButton.heightAnchor.constraint(equalToConstant: 40),
            userLocationButton.widthAnchor.constraint(equalToConstant: 40)
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
    
    func configureAlertController() {
        let yesAction = UIAlertAction(title: "Evet", style: .default) {[weak self] _ in
            guard let self = self else { return }
            let authStatus = self.locationAuthService.getAuthorizationStatus()
            
            if authStatus == .notDetermined {
                self.authorizationService.requestAuthorization(for: locationAuthService)
                return
            }
        
            handleLocationAuthorization(fromUserAction: true)
        }

        let noAction = UIAlertAction(title: "Hayır", style: .cancel) { _ in }

        alertController.addAction(yesAction)
        alertController.addAction(noAction)
    }
    
    func configureButtons() {
        userLocationButton.translatesAutoresizingMaskIntoConstraints = false

        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
        let image = UIImage(systemName: "safari", withConfiguration: config)?.withTintColor(.accent, renderingMode: .alwaysOriginal)

        userLocationButton.setImage(image, for: .normal)
        userLocationButton.imageView?.contentMode = .scaleAspectFit

        userLocationButton.layer.cornerRadius = 20
        userLocationButton.layer.masksToBounds = true
        userLocationButton.backgroundColor = .gray.withAlphaComponent(0.5)

        userLocationButton.addTarget(self, action: #selector(didTapLocationButton), for: .touchUpInside)
    }
}

///MapView Delegate extension
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }

        let identifier = "LocationMarker"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView

        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        
        ///If annotation is user, configure it based on the situation.
        if annotation.title == "Sen" {
            annotationView?.markerTintColor = .systemBlue
            annotationView?.glyphText = "🧍"
        }

        return annotationView
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let selectedAnnotation = view.annotation else { return }

        for annotation in mapView.annotations {
            if let annotationView = mapView.view(for: annotation) as? MKMarkerAnnotationView,
               annotation !== selectedAnnotation {
                DispatchQueue.main.async {
                    if annotation.title != "Sen" {
                        annotationView.markerTintColor = .systemRed
                        annotationView.glyphText = nil
                    }
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
        guard let annotation = mapView.annotations.first(where: { $0.title != "Sen" && $0.title == locations?.first?.name }),
              mapView.selectedAnnotations.isEmpty else { return }

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
            let annotation = createAnnotation(title: location.name,
                                              lat: CGFloat(location.coordinates.lat),
                                              lon: CGFloat(location.coordinates.lng))
            annotations.append(annotation)
        }

        mapView.addAnnotations(annotations)
        mapView.showAnnotations(annotations, animated: false)
    }
    
    func createAnnotation(title: String, lat: CGFloat, lon: CGFloat) -> MKPointAnnotation {
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.coordinate = CLLocationCoordinate2D(
            latitude: lat,
            longitude: lon
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
    
    func handleLocationAuthorization(fromUserAction: Bool = false) {
        let authStatus = locationAuthService.getAuthorizationStatus()
        
        switch authStatus {
        case .notDetermined:
            present(alertController, animated: true)
        case .restricted, .denied:
            if fromUserAction {
                openSettings()
            } else {
                present(alertController, animated: true)
            }
        case .authorizedAlways, .authorizedWhenInUse, .authorized:
            handleUserLocation()
        @unknown default:
            break
        }
    }
    
    func handleUserLocation() {
        Task {
            let result = try await locationService.requestLocation()
            await MainActor.run { [weak self] in
                guard let self = self else { return }
                self.userLocation = result

                let annotation = createAnnotation(title: "Sen", lat: result.coordinate.latitude, lon: result.coordinate.longitude)
                self.mapView.addAnnotation(annotation)
            }
        }
    }
    
    @objc
    func didTapLocationButton() {
        if let userLocation = userLocation {
            let lat = userLocation.coordinate.latitude
            let lon = userLocation.coordinate.longitude
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: lon), span: span)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.mapView.setRegion(region, animated: true)
            }
        } else {
            handleLocationAuthorization(fromUserAction: true)
        }
    }
    
    func openSettings() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString),
           UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL)
        }
    }
}

