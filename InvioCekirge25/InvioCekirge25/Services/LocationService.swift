//
//  LocationService.swift
//  InvioCekirge25
//
//  Created by Mertcan Kırcı on 31.03.2025.
//

import CoreLocation

class LocationService: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var locationHandler: ((Result<CLLocation, Error>) -> Void)?
    private var currentTask: Task<CLLocation, Error>?
    private let cache = NSCache<AnyObject, AnyObject>()
    private let period: Float = 30.0 //Time period for cache to return value.
    
    override init() {
        super.init()
        manager.delegate = self
    }

    func requestLocation() async throws -> CLLocation {
        
        if let currentTask = currentTask {
            return try await currentTask.value
        }

        let task = Task<CLLocation, Error> {
            try await withCheckedThrowingContinuation { continuation in
                self.locationHandler = { [weak self] result in
                    self?.currentTask = nil
                    switch result {
                    case .success(let location):
                        continuation.resume(returning: location)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
                self.manager.requestWhenInUseAuthorization()
                self.manager.requestLocation()
            }
        }

        self.currentTask = task
        return try await task.value
    }
    
    
    /// This function migrates requestLocation() and getCachedLocation() functions. If we have a cached location we simply adjust it on the map until our new location arrives. If the distance between our cached location and new (updated) location is smaller then 300 meters we simply return the cached location.
    /// - Parameters:
    ///   - onImmediateLocation: Returns cached location if we have it.
    ///   - onUpdatedLocation: Return updated location if it's distance greater than 300 meters.
    func requestSmartLocation(onImmediateLocation: ((CLLocation) -> Void)?, onUpdatedLocation: ((Result<CLLocation, Error>) -> Void)?) {
        if let cachedLocation = self.getCachedLocation() {
            onImmediateLocation?(cachedLocation)
        }
        
        Task {
            do {
                let updatedLocation = try await requestLocation()
                
                if let cachedLocation = self.getCachedLocation() {
                    let distance = cachedLocation.distance(from: updatedLocation)
                    
                    if distance > 300 {
                        onUpdatedLocation?(.success(updatedLocation))
                    }
                } else {
                    onUpdatedLocation?(.success(updatedLocation))
                }
            } catch {
                onUpdatedLocation?(.failure(error))
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationHandler?(.success(location))
            locationHandler = nil
            Log.success("Found user's location.")
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationHandler?(.failure(error))
        locationHandler = nil
        Log.error("Failed to find user's location.")
    }
    
    func getCachedLocation() -> CLLocation? {
        return manager.location
    }
}


