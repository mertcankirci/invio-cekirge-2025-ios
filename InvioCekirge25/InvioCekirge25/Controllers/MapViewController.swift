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
    var isFromDetailVC: Bool?
    
    weak var coordinator: MapCoordinator?
    let mapView = MKMapView()
    let alertController = UIAlertController(title: "Alert", message: "Kendi konumunu haritada görmek ister misin?", preferredStyle: .alert)
    private let userLocationButton = UIButton()
    private var userLocation: CLLocation?
    private let getDirectionButton = UIButton()
    
    //MARK: - Services
    private let authorizationService = AuthorizationService()
    private let locationAuthService = LocationAuthorizationService()
    private let locationService = LocationService()
    
    lazy var collectionView: UICollectionView = {
        let layout = snapToCenterLocationListLayout()
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collection
    }()
    
    private var collectionViewWillScroll: Bool = false
    
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
        
        if self.isMovingFromParent || self.isBeingDismissed {
            coordinator?.coordinatorDidFinish()
        }
    }
    
    func configureUI() {
        [mapView, collectionView, userLocationButton, getDirectionButton].forEach { component in
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
            userLocationButton.widthAnchor.constraint(equalToConstant: 40),
            
            getDirectionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            getDirectionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            getDirectionButton.heightAnchor.constraint(equalToConstant: 50),
            getDirectionButton.widthAnchor.constraint(equalToConstant: 200)
        ])
        
        if isFromDetailVC == true {
            collectionView.isHidden = true
            getDirectionButton.isHidden = false
        } else {
            collectionView.isHidden = false
            getDirectionButton.isHidden = true
        }
    }
    
    func configureVC() {
        view.backgroundColor = InvioColors.groupedBackground
        ///This is for navigation bar + status bar height. We'll need to adjust topBlurView's height anchor based on this properties in detailLocationVC.
        navigationItem.largeTitleDisplayMode = .never
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
        
        let image = InvioImages.compass?.withSymbolSize(22, weight: .semibold)?.withTintColor(.accent, renderingMode: .alwaysOriginal)
        
        userLocationButton.setImage(image, for: .normal)
        userLocationButton.imageView?.contentMode = .scaleAspectFit
        
        userLocationButton.layer.cornerRadius = 20
        userLocationButton.layer.masksToBounds = true
        userLocationButton.backgroundColor = InvioColors.transparentGrayButtonBackground
        userLocationButton.addTarget(self, action: #selector(didTapLocationButton), for: .touchUpInside)
        
        getDirectionButton.translatesAutoresizingMaskIntoConstraints = false
        getDirectionButton.setTitle("Yol tarifi al", for: .normal)
        getDirectionButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        getDirectionButton.setTitleColor(.label, for: .normal)
        getDirectionButton.backgroundColor = InvioColors.background
        getDirectionButton.layer.cornerRadius = 8
        getDirectionButton.layer.borderWidth = 2
        getDirectionButton.layer.borderColor = UIColor.accent.cgColor
        getDirectionButton.addTarget(self, action: #selector(didTapGetDirectionsButton), for: .touchUpInside)
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
            annotationView?.markerTintColor = InvioColors.userMarkerTintColor
            annotationView?.glyphText = "🧍"
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let selectedAnnotation = view.annotation else { return }
        collectionViewWillScroll = true
        
        for annotation in mapView.annotations {
            if let annotationView = mapView.view(for: annotation) as? MKMarkerAnnotationView,
               annotation !== selectedAnnotation {
                DispatchQueue.main.async {
                    if annotation.title != "Sen" {
                        annotationView.markerTintColor = InvioColors.defaultmarkerTintColor
                        annotationView.glyphText = nil
                    }
                }
            }
        }
        
        if let selectedView = mapView.view(for: selectedAnnotation) as? MKMarkerAnnotationView {
            let name = selectedAnnotation.title
            let index = (locations?.firstIndex(where: { $0.name == name })) ?? 0 ///fallback to 0 to ensure there isn't any crashes
            let indexPath = IndexPath(row: index, section: 0)
            DispatchQueue.main.async {
                selectedView.markerTintColor = .accent
                selectedView.glyphText = "★"
            }
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true) ///scroll to collection view item when annotation changes
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.collectionViewWillScroll = false
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
        cell.delegate = self
        cell.set(for: location)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let location = locations?[indexPath.row] else { return }
        
        if let annotation = mapView.annotations.first(where: { $0.title == location.name }) {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.mapView.selectAnnotation(annotation, animated: true)
                self.setRegionForAnnotation(for: annotation)
            }
        }
    }
}

///Custom functions extension
extension MapViewController {
    private func addPin() {
        guard let locations = locations, locations.count > 0 else { Log.warning("No locations found on Map VC"); return }
        
        var annotations: [MKPointAnnotation] = []
        
        for location in locations {
            let annotation = createAnnotation(title: location.name, lat: CGFloat(location.coordinates.lat), lon: CGFloat(location.coordinates.lng))
            annotations.append(annotation)
        }
        
        mapView.addAnnotations(annotations)
        mapView.showAnnotations(annotations, animated: false)
    }
    
    func createAnnotation(title: String, lat: CGFloat, lon: CGFloat) -> MKPointAnnotation {
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        return annotation
    }
    
    func setRegionForAnnotation(for annotation: MKAnnotation) {
        let lat = annotation.coordinate.latitude
        let lon = annotation.coordinate.longitude
        let center = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    /// Handles the location authorization flow
    /// - Parameter fromUserAction: Did user call the function from the location button.
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
        Task { [weak self] in
            guard let self = self else { return }

            await self.locationService.requestSmartLocation { cachedLocation in
                self.userLocation = cachedLocation
                
                await MainActor.run {
                    self.showUserAnnotation(for: cachedLocation)
                }
                
                self.sortLocations()
            } onUpdatedLocation: { result in
                switch result {
                case .success(let location):
                    self.userLocation = location
                    
                    await MainActor.run {
                        self.showUserAnnotation(for: location)
                    }
                    
                    self.sortLocations()
                case .failure(let error):
                    await MainActor.run {
                        self.presentAlert(errorMessage: error.localizedDescription)
                    }
                }
            }
        }
    }

    
    private func showUserAnnotation(for location: CLLocation) {
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        let annotationToAdd = createAnnotation(title: "Sen", lat: lat, lon: lon)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if let toRemove = self.mapView.annotations.first(where: { $0.title == "Sen" }) {
                self.mapView.removeAnnotation(toRemove)
            }
            
            self.mapView.addAnnotation(annotationToAdd)
        }
    }
    
    @objc
    func didTapLocationButton() {
        if let userLocation = userLocation {
            let lat = userLocation.coordinate.latitude
            let lon = userLocation.coordinate.longitude
            let annotation = createAnnotation(title: "Sen", lat: lat, lon: lon)
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: lon), span: span)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.mapView.addAnnotation(annotation)
                self.mapView.setRegion(region, animated: true)
            }
        } else {
            handleLocationAuthorization(fromUserAction: true)
        }
    }
    
    @objc
    func didTapGetDirectionsButton() {
        guard let location = self.locations?.first else { return }
        let latitude = location.coordinates.lat
        let longitude = location.coordinates.lng
        
        //app urls
        let appleURL = "http://maps.apple.com/?daddr=\(latitude),\(longitude)"
        let googleURL = "comgooglemaps://?daddr=\(latitude),\(longitude)&directionsmode=driving"
        let yandexURL = "yandexnavi://build_route_on_map?lat_to=\(latitude)&lon_to=\(longitude)"

        
        let googleItem = ("Google Maps", URL(string: googleURL)!)
        let yandexItem = ("Yandex Navi", URL(string: yandexURL)!)
        
        var installedNavigationApps = [("Apple Maps", URL(string:appleURL)!)]
        
        if UIApplication.shared.canOpenURL(googleItem.1) {
            installedNavigationApps.append(googleItem)
        }
        
        if UIApplication.shared.canOpenURL(yandexItem.1) {
            installedNavigationApps.append(yandexItem)
        }
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for app in installedNavigationApps {
            let button = UIAlertAction(title: app.0, style: .default, handler: { _ in
                UIApplication.shared.open(app.1, options: [:], completionHandler: nil)
            })
            alert.addAction(button)
        }
        let cancel = UIAlertAction(title: "Vazgeç", style: .cancel, handler: nil)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    func openSettings() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString),
           UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL)
        }
    }
    
    //Collection view layout (select the location based on the scroll on collection view)
    private func snapToCenterLocationListLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .absolute(120))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.interGroupSpacing = 16

        section.visibleItemsInvalidationHandler = { [weak self] visibleItems, offset, environment in
            guard let self = self else { return }

            let centerX = offset.x + environment.container.contentSize.width / 2

            let sorted = visibleItems.sorted {
                abs($0.frame.midX - centerX) < abs($1.frame.midX - centerX)
            }

            if let centerItem = sorted.first {
                let indexPath = centerItem.indexPath
                self.selectVisibleCell(for: indexPath)
            }
        }

        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func selectVisibleCell(for indexPath: IndexPath) {
        if !collectionViewWillScroll {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if let location = self.locations?[indexPath.item],
                   let annotation = self.mapView.annotations.first(where: { $0.title == location.name }) {
                    self.mapView.selectAnnotation(annotation, animated: true)
                    self.setRegionForAnnotation(for: annotation)
                }
            }
        }
    }
    
    /// Helper function that calculates the distance between user location and given location.
    /// - Parameter location: Desired location for distance calculation
    private func calculateDistance(to location: LocationModel) -> Double? {
        guard let userLocation = userLocation else { return nil }
        
        let locationLat = CLLocationDegrees(location.coordinates.lat)
        let locationLon = CLLocationDegrees(location.coordinates.lng)
        let clLocation = CLLocation(latitude: locationLat, longitude: locationLon)
        
        return clLocation.distance(from: userLocation)
    }
    
    /// Sorts locations based on their distanceFromUser property with Comparable protocol -see LocationModel for more- on background thread.
    /// - Parameters:
    ///   - locations: locations array
    ///   - userLocation: user location
    /// - Returns: sorted locations
    private func calculateSortedLocations(from locations: [LocationModel], userLocation: CLLocation) -> [LocationModel] {
        var updated = locations
        for i in updated.indices {
            let lat = Double(updated[i].coordinates.lat)
            let lon = Double(updated[i].coordinates.lng)
            let distance = userLocation.distance(from: CLLocation(latitude: lat, longitude: lon))
            updated[i].distanceFromUser = distance
        }
        return updated.sorted()
    }
    
    
    /// Applies sorted locations to the UI on main thread
    /// - Parameter sorted: sorted locations array
    @MainActor
    private func applySortedLocations(_ sorted: [LocationModel]) {
        if sorted != locations {
            self.locations = sorted
            self.collectionView.reloadData()
            self.showToast(message: "Lokasyonlar konumunuza göre düzenlendi.")
            
            if let annotation = mapView.annotations.first(where: { $0.title == sorted.first?.name }) {
                self.mapView.selectAnnotation(annotation, animated: true)
                self.setRegionForAnnotation(for: annotation)
            }
        }
    }
    
    /// Sorts locations, applies updates thread safe.
    private func sortLocations() {
        Task.detached { [weak self] in
            guard let self = self,
                  let locations = await self.locations,
                  let userLocation = await self.userLocation else { return }
            
            let sorted = await self.calculateSortedLocations(from: locations, userLocation: userLocation)
            
            await MainActor.run {
                self.applySortedLocations(sorted)
            }
        }
    }
}

//cell delegates
extension MapViewController: LocationListCollectionViewCellDelegate {
    func didTapDetailButton(location: LocationModel) {
        guard let cityName = self.title else { return }
        coordinator?.navigateToLocationDetail(location: location, cityName: cityName)
    }
}

