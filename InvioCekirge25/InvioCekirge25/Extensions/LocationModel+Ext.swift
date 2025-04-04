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
}
