//
//  PersistenceService.swift
//  InvioCekirge25
//
//  Created by Mertcan Kırcı on 4.04.2025.
//

import Foundation

class PersistenceService {
    static let shared = PersistenceService()
    
    private let defaults: UserDefaults
    private let favoriteLocationsKey = "invio-fav-loc-key"
    
    private var locations: [LocationModel] = []
    private var locationIDs: Set<Int> = [] ///For fast lookup in mainVC

    var favoriteLocations: [LocationModel] {
        return locations
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        do {
            try loadFavoriteLocations()
        } catch {
            Log.error("There was an error initializing Persistence Service.")
            self.locations = []
            self.locationIDs = []
        }
    }
    
    /// Loads favorite locations from user defaults
    private func loadFavoriteLocations() throws {
        guard let data = defaults.data(forKey: favoriteLocationsKey) else {
            Log.error("Couldn't find the favorite location key.")
            throw PersistenceError.noDataFound
        }

        let decoder = JSONDecoder()

        do {
            let decoded = try decoder.decode([LocationModel].self, from: data)
            self.locations = decoded
            self.locationIDs = Set(decoded.map { $0.id })
        } catch {
            Log.error("Error decoding favorite locations")
            throw PersistenceError.decodingFailed
        }
    }
    
    /// Saves location to users' favorites on userdefaults
    /// - Parameter location: location to favorite
    func saveFavLocation(for location: LocationModel) throws {
        guard !locationIDs.contains(location.id) else {
            Log.warning("Location already in favorites.")
            throw PersistenceError.locationAlreadyExists
        }

        locations.append(location)
        locationIDs.insert(location.id)

        do {
            try encodeAndSaveFavLocations()
        } catch {
            throw error
        }
    }
    
    /// Deletes favorites location from user defaults
    /// - Parameter location: location to delete
    func deleteFavLocation(for location: LocationModel) throws {
        guard locationIDs.contains(location.id) else {
            Log.warning("Location doesn't exist in favorites.")
            throw PersistenceError.locationDoesNotExist
        }

        locations.removeAll(where: { $0.id == location.id })
        locationIDs.remove(location.id)
        
        do {
            try encodeAndSaveFavLocations()
            Log.success("Deleted location successfully.")
        } catch {
            throw error
        }
    }
    
    /// Returns if a location is favorite location. Does this by looking locationIDs array so the lookup complexity is O(1) instad of O(n).
    /// - Parameter location: location to investigate
    /// - Returns: if location is in favorites
    func isFavorite(location: LocationModel) -> Bool {
        return locationIDs.contains(location.id)
    }
    
    /// Encodes and saves favorite location.
    private func encodeAndSaveFavLocations() throws {
        let encoder = JSONEncoder()

        do {
            let data = try encoder.encode(locations)
            defaults.set(data, forKey: favoriteLocationsKey)
            Log.success("Location saved to favorites.")
        } catch {
            Log.error("Failed to encode favorite locations")
            throw PersistenceError.encodingFailed
        }
    }
}
