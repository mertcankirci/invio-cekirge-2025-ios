//
//  LocationModel.swift
//  InvioCekirge25
//
//  Created by Mertcan Kırcı on 26.03.2025.
//

import Foundation

struct LocationModel: Codable, Comparable {
    let name: String //name
    let description: String
    let coordinates: CoordinateModel
    let image: String?
    let id: Int
    
    //We'll use this for calculating the distance between the user and desired location.
    var distanceFromUser: Double?
    //We'll use this for showing cty name in location detailVC.
    var locationsCity: String?
    
    enum CodingKeys: String, CodingKey {
        case name, description, coordinates, image, id
    }
    
    static func < (lhs: LocationModel, rhs: LocationModel) -> Bool {
        switch (lhs.distanceFromUser, rhs.distanceFromUser) {
        case let (l?, r?):
            return l < r
        case (nil, _?):
            return false
        case (_?, nil):
            return true
        default:
            return false
        }
    }
}

struct CoordinateModel: Codable {
    let lat: Float
    let lng: Float
}
