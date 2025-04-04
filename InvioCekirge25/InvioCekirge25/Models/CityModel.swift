//
//  CityModel.swift
//  InvioCekirge25
//
//  Created by Mertcan Kırcı on 27.03.2025.
//

import Foundation

class CityModel: Codable {
    let city: String
    let locations: [LocationModel]
    ///We'll use the rest in UI layer. This is why they aren't in the coding keys enum.
    var isExpanded: Bool = false
    var cellImage: String? {
        let validLocations = locations.filter({ $0.image != nil })
        return validLocations.randomElement()?.image
    }
    
    enum CodingKeys: String, CodingKey {
        case city, locations
    }
}
