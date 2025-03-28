//
//  CityModel.swift
//  InvioCekirge25
//
//  Created by Mertcan Kırcı on 27.03.2025.
//

import Foundation

struct CityModel: Codable {
    let city: String
    let locations: [LocationModel]
    ///We'll use isExpanded in UI layer. This is why it isn't in the coding keys enum.
    var isExpanded: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case city, locations
    }
}
