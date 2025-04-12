//
//  LocationService+Tests.swift
//  InvioCekirge25Tests
//
//  Created by Mertcan Kırcı on 12.04.2025.
//

import Testing
import CoreLocation
@testable import InvioCekirge25

class MockLocationManager: LocationManagerProtocol {
    var delegate: CLLocationManagerDelegate?
    var location: CLLocation?
    var didCallRequestLocation = false
    
    func requestLocation() {
        didCallRequestLocation = true
    }
}

@Suite("LocatianService Tests")
struct LocationServiceTests {
    @Test("requestLocation should return location when delegate is called")
    func testRequestLocationSuccess() async throws {
        let expectedLocation = CLLocation(latitude: 41.0, longitude: 29.0)
        let mockManager = MockLocationManager()
        let service = LocationService(manager: mockManager)
        
        let task = Task {
            try await service.requestLocation()
        }
        
        mockManager.delegate?.locationManager?(CLLocationManager(), didUpdateLocations: [expectedLocation])
        let result = try await task.value

        #expect(result.coordinate.latitude == 41.0)
        #expect(result.coordinate.longitude == 29.0)
    }
    
    @Test("requestLocation should return error on delegate")
    func testRequestLocationFailure() async throws {
        let mockManager = MockLocationManager()
        let service = LocationService(manager: mockManager)
        
        let task = Task {
            try await service.requestLocation()
        }
        
        let expectedError = NSError(domain: "MockError", code: 404)
        mockManager.delegate?.locationManager?(CLLocationManager(), didFailWithError: expectedError)
        
        do {
            _ = try await task.value
        } catch {
            #expect((error as NSError).code == 404)
        }
    }
    
    @Test("requestLocation should return same task when called concurrently")
    func testRequestLocationSameTask() async throws {
        let expectedLocation = CLLocation(latitude: 40.0, longitude: 30.0)
        let mockManager = MockLocationManager()
        let service = LocationService(manager: mockManager)
        
        let task1 = Task {
            try await service.requestLocation()
        }
        
        let task2 = Task {
            try await service.requestLocation()
        }
        
        service.locationManager(CLLocationManager(), didUpdateLocations: [expectedLocation])
        
        let result1 = try await task1.value
        let result2 = try await task2.value
        
        #expect(result1 == result2)
    }
    
    @Test("getCachedLocation should return the mock location")
    func testGetCachedLocationReturnsMockLocation() {
        let mockLocation = CLLocation(latitude: 40.0, longitude: 30.0)
        let mockManager = MockLocationManager()
        mockManager.location = mockLocation
        
        let service = LocationService(manager: mockManager)
        let cached = service.getCachedLocation()
        
        #expect(cached == mockLocation)
    }
}
