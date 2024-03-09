//
//  MoviesModel.swift
//  MaxMovies
//
//  Created by Max zam on 09/03/2024.
//

import Foundation

struct MovieResponse: Codable, Equatable {
    
    var page: Int
    var results: [Movie]
    var totalPages: Int
    
    enum CodingKeys: String, CodingKey {
        case page = "page"
        case results = "results"
        case totalPages = "total_pages"
    }
}

struct Movie: Codable, Identifiable, Equatable, MediaDetails {
    
    // Computed property to make it conform to MediaDetails protocol
    var releaseDate: String? {
        return originalReleaseDate
    }
    
    let genreIds: [Int]
    var genres: [String] = []
    let id: Int
    let overview: String
    let posterPath: String?
    let backDrop: String?
    let originalReleaseDate: String
    let title: String
    let voteAverage: Double
    let voteCount: Int
    let mediaType: String?
    var uid = UUID()
    
    enum CodingKeys: String, CodingKey {
        case genreIds = "genre_ids"
        case id = "id"
        case overview = "overview"
        case posterPath = "poster_path"
        case backDrop = "backdrop_path"
        case originalReleaseDate = "release_date"
        case title = "title"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case mediaType = "media_type"
    }
}

struct Genres: Codable {
    let genres: [Genre]
    
    struct Genre: Codable {
        let id: Int
        let name: String
    }
}

protocol MediaDetails {
    var title: String { get }
    var overview: String { get }
    var backDrop: String? { get }
    var posterPath: String? { get }
    var releaseDate: String? { get }
    var voteAverage: Double { get }
    var voteCount: Int { get }
    var genres: [String] { get }
    var id: Int { get }
}

