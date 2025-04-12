//
//  Authorization.swift
//  InvioCekirge25
//
//  Created by Mertcan Kırcı on 31.03.2025.
//

import CoreLocation

///Base protocol for authorization service
protocol Authorizable {
    func requestAuthorization()
}

///Location authorization protocol (we could need it in the future [more scalable])
protocol LocationAuthorizable: Authorizable {}

class LocationAuthorizationService: LocationAuthorizable {
    
    let manager: CLLocationManager
    
    init(manager: CLLocationManager = CLLocationManager()) {
        self.manager = manager
    }
    
    func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
    }
    
    func getAuthorizationStatus() -> CLAuthorizationStatus {
        return manager.authorizationStatus
    }
}

///Main class to request authorization
class AuthorizationService {
    /// Requests authorization for all classes that conforms Authorizable
    /// - Parameter type: Object that conforms Authorizable
    func requestAuthorization(for type: Authorizable) {
        type.requestAuthorization()
    }
}
