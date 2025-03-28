//
//  LocationModel.swift
//  InvioCekirge25
//
//  Created by Mertcan Kırcı on 26.03.2025.
//

import Foundation

struct LocationModel: Codable {
    let name: String //name
    let description: String
    let coordinates: CoordinateModel
    let image: String?
    let id: Int 
}

struct CoordinateModel: Codable {
    let lat: Float
    let lng: Float
}
