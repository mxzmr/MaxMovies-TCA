//
//  ReviewsResponse.swift
//  MaxMovies
//
//  Created by Max zam on 09/03/2024.
//
import Foundation

struct ReviewsResponse: Codable, Identifiable, Equatable {
    let id: Int
    let page: Int
    let results: [Review]?
    let totalPages: Int
    
    struct Review: Codable, Identifiable, Equatable {
        let author: String
        let authorDetails: AuthorDetails
        let content: String
        
        var id: String {
            UUID().uuidString
        }
        
        struct AuthorDetails: Codable, Equatable {
            let rating: Double?
        }
        
        enum CodingKeys: String, CodingKey {
            case author
            case authorDetails = "author_details"
            case content
        }
    }
    enum CodingKeys: String, CodingKey {
        case id
        case page
        case results
        case totalPages = "total_pages"
    }
}
