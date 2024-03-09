//
//  NetworkService.swift
//  MaxMovies
//
//  Created by Max zam on 09/03/2024.
//

import Foundation
import ComposableArchitecture

protocol NetworkService {
    func fetch<T: Codable> ( url: URL?, headers: [String: String]?) async throws -> T
}


struct NetworkClient: NetworkService {
    
    func fetch<T: Codable>(url: URL?, headers: [String: String]? = nil) async throws -> T {
        guard let urlAddress = url else {
            throw NetworkError.invalidURL
        }
        
        var urlRequest = URLRequest(url: urlAddress)
        urlRequest.allHTTPHeaderFields = headers
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.statusCodeError((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        
        let decodedData = try JSONDecoder().decode(T.self, from: data)
        
        return decodedData
    }
}

enum NetworkError: Error {
    case invalidURL
    case decodingError(Error)
    case requestFailed(Error)
    case invalidResponse
    case statusCodeError(Int)
}

private enum NetworkServiceKey: DependencyKey {
    static let liveValue: NetworkService = NetworkClient()
}

extension DependencyValues {
  var networkService: NetworkService {
    get { self[NetworkServiceKey.self] }
    set { self[NetworkServiceKey.self] = newValue }
  }
}
