//
//  LocationModel+Ext.swift
//  InvioCekirge25
//
//  Created by Mertcan Kırcı on 4.04.2025.
//

import Foundation

extension LocationModel: Equatable {
    static func == (lhs: LocationModel, rhs: LocationModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    //for testing purposes
    static func mock(id: Int = 1, name: String = "Mockşehir", description: String = "Test açıklaması", latitude: Float = 0.0, longitude: Float = 0.0, image: String? = nil) -> LocationModel {
        return LocationModel(
            name: name,
            description: description,
            coordinates: CoordinateModel(lat: latitude, lng: longitude),
            image: image,
            id: id
        )
    }
}
