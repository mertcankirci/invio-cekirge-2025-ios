//
//  APIService+Tests.swift
//  InvioCekirge25Tests
//
//  Created by Mertcan Kırcı on 11.04.2025.
//

import Testing
import Foundation
@testable import InvioCekirge25

class MockURLProtocol: URLProtocol {
    static var mockResponseData: Data?
    static var mcokStatusCode: Int = 200
    
    override class func canInit(with request: URLRequest) -> Bool { true }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        if let data = MockURLProtocol.mockResponseData {
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: MockURLProtocol.mcokStatusCode,
                httpVersion: nil,
                headerFields: nil
            )!
            self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            self.client?.urlProtocol(self, didLoad: data)
        }
        self.client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

class MockAPIService: APIService {
    private let session: URLSession
    private let baseUrl = "https://storage.googleapis.com/invio-com/usg-challenge/city-location/page-"
    
    init(session: URLSession) {
        self.session = session
    }
    
    override func fetchData(for page: Int = 1) async throws -> LocationResultModel {
        let urlString = baseUrl + "\(page).json"
        guard let url = URL(string: urlString) else { throw NetworkError.notFound }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let (data, response) = try await session.data(for: request)
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode else { throw NetworkError.notFound }
        try validateResponse(statusCode: statusCode)

        return try JSONDecoder().decode(LocationResultModel.self, from: data)
    }
}

@Suite("API Service Tests")
struct APIServiceTests {
    @Test("fetchData should return valid model")
    func testDataFetch() async throws {
        let mockJSON = """
        {"currentPage":1,
        "totalPage":4,
        "total":62,
        "itemPerPage":20,
        "pageSize":20,
        "data": [
            {"city":"Adana",
                    "locations":
                                [{"name": "Taşköprü","description":"Roma döneminde inşaa edilen, Seyhan Nehri üzerinde bulunan tarihi köprü.","coordinates":{"lat":37.0017,"lng":35.3213},"image":"https://upload.wikimedia.org/wikipedia/commons/4/4a/Ta%C5%9Fk%C3%B6pr%C3%BC%27n%C3%BCn_Panoramik_Foto%C4%9Fraf%C4%B1.jpg","id":1}]
        }
        ]
        }
        """.data(using: .utf8)!
        
        MockURLProtocol.mockResponseData = mockJSON
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        
        let apiService = MockAPIService(session: session)
        
        let result = try await apiService.fetchData()
        #expect(result.data.first?.city == "Adana")
        #expect(result.data.count == 1)
        #expect(result.data.first?.locations.first?.name == "Taşköprü")
        #expect(result.data.first?.locations.count == 1)
    }
}
