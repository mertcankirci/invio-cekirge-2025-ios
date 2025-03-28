//
//  LocationResultModel.swift
//  InvioCekirge25
//
//  Created by Mertcan Kırcı on 26.03.2025.
//

import Foundation

struct LocationResultModel: Codable {
    let currentPage: Int
    let totalPage: Int
    let total: Int
    let itemPerPage: Int
    let pageSize: Int
    let data: [CityModel]
}
