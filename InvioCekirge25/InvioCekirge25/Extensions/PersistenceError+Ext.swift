//
//  PersistenceError+Ext.swift
//  InvioCekirge25
//
//  Created by Mertcan Kırcı on 4.04.2025.
//

import Foundation

extension PersistenceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .locationAlreadyExists:
            return "This location is already in favorites."
        case .locationDoesNotExist:
            return "Couldn't find location in favorites"
        case .encodingFailed:
            return "There was an error while saving the data."
        case .decodingFailed:
            return "There was an error while loading the data."
        case .noDataFound:
            return "Couldn't find data."
        }
    }
}
