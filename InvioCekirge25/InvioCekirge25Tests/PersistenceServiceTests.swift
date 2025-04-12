//
//  PersistenceServiceTests.swift
//  InvioCekirge25Tests
//
//  Created by Mertcan Kırcı on 12.04.2025.
//

import Testing
import Foundation
@testable import InvioCekirge25

class MockPersistenceService: PersistenceServiceProtocol {
    private var savedLocations = [LocationModel]()
    private var savedLocationIds = Set<Int>()
    
    func saveFavLocation(for location: InvioCekirge25.LocationModel) throws {
        let id = location.id
        savedLocations.append(location)
        savedLocationIds.insert(id)
    }
    
    func deleteFavLocation(for location: LocationModel) throws {
        let id = location.id
        savedLocations.removeAll(where: { $0 == location })
        savedLocationIds.remove(id)
    }
    
    func isFavorite(location: LocationModel) -> Bool {
        return savedLocationIds.contains(location.id)
    }
    
    var favoriteLocations: [InvioCekirge25.LocationModel] {
        return savedLocations
    }
}

@Suite("PersistenceService Tests")
struct PersistenceServiceTests {
    @Test("Saved location should appear in favorites list")
    func testSaveFavLocation() async throws {
        let service = MockPersistenceService()
        let location = LocationModel.mock(id: 1)

        try service.saveFavLocation(for: location)

        #expect(service.favoriteLocations.contains(location))
        #expect(service.isFavorite(location: location))
    }
    
    @Test("Deleted location should be removed from favorites")
    func testDeleteFavLocation() async throws {
        let service = MockPersistenceService()
        let location = LocationModel.mock(id: 2)

        try service.saveFavLocation(for: location)
        try service.deleteFavLocation(for: location)

        #expect(!service.favoriteLocations.contains(location))
        #expect(!service.isFavorite(location: location))
    }
    
    @Test("Deleting a non-existing location should not crash (mock behavior)")
    func testDeleteNonExistingFavLocation() async throws {
        let service = MockPersistenceService()
        let location = LocationModel.mock(id: 999)

        try service.deleteFavLocation(for: location)

        #expect(service.favoriteLocations.isEmpty)
    }
}
