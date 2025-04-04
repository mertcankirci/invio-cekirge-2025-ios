//
//  NetworkError+Ext.swift
//  InvioCekirge25
//
//  Created by Mertcan Kırcı on 4.04.2025.
//

import Foundation

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .success:
            return "The request was successful."
        case .informational:
            return "Informational response received."
        case .redirection:
            return "The request was redirected."
        case .badRequest:
            return "Bad request. Please check your input."
        case .unauthorized:
            return "Unauthorized. Please log in."
        case .forbidden:
            return "Forbidden. You don't have permission."
        case .notFound:
            return "Not found. The requested resource doesn’t exist."
        case .clientError(let code):
            return "Client error occurred (Code \(code))."
        case .serverError(let code):
            return "Server error occurred (Code \(code))."
        case .unknownStatus(let code):
            return "Unexpected status code: \(code)."
        }
    }
}
