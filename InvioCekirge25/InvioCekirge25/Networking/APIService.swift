//
//  APIService.swift
//  InvioCekirge25
//
//  Created by Mertcan Kırcı on 26.03.2025.
//q

import Foundation

class APIService {
    private let baseUrl = "https://storage.googleapis.com/invio-com/usg-challenge/city-location/page-"
    
    //fetch data from api with pagination
    func fetchData(for page: Int = 1) async throws -> LocationResultModel {
        let urlString = baseUrl + "\(page).json"
        guard let url = URL(string: urlString) else { throw NetworkError.notFound }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else { throw NetworkError.notFound }
            try validateResponse(statusCode: statusCode)
            
            let decodedData = try JSONDecoder().decode(LocationResultModel.self, from: data)
            Log.success("Data fetched successfully.")
            
            return decodedData
        } catch {
            print(error)
            Log.error("Error while fetching data.")
            throw error
        }
    }
    
    func validateResponse(statusCode: Int) throws {
        let status = NetworkError.networkStatus(for: statusCode)
        if case .success = status {
            return
        } else {
            throw status
        }
    }
}
