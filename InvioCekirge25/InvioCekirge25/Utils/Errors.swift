//
//  Errors.swift
//  InvioCekirge25
//
//  Created by Mertcan Kırcı on 26.03.2025.
//

import Foundation

enum NetworkError: Error {
    case success
    case informational
    case redirection
    case badRequest
    case unauthorized
    case forbidden
    case notFound
    case clientError(code: Int)
    case serverError(code: Int)
    case unknownStatus(code: Int)
    
    static func networkStatus(for statusCode: Int) -> NetworkError {
        switch statusCode {
        case 100..<200:
            return .informational
        case 200..<300:
            return .success
        case 300..<400:
            return .redirection
        case 400:
            return .badRequest
        case 401:
            return .unauthorized
        case 403:
            return .forbidden
        case 404:
            return .notFound
        case 400..<500:
            return .clientError(code: statusCode)
        case 500..<600:
            return .serverError(code: statusCode)
        default:
            return .unknownStatus(code: statusCode)
        }
    }

}

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

extension NetworkError: CustomNSError {
    static var errorDomain: String {
        return "com.yourapp.network"
    }

    var errorCode: Int {
        switch self {
        case .success: return 200
        case .informational: return 100
        case .redirection: return 300
        case .badRequest: return 400
        case .unauthorized: return 401
        case .forbidden: return 403
        case .notFound: return 404
        case .clientError(let code),
             .serverError(let code),
             .unknownStatus(let code):
            return code
        }
    }

    var errorUserInfo: [String : Any] {
        return [
            NSLocalizedDescriptionKey: self.errorDescription ?? "Unknown network error"
        ]
    }
}



