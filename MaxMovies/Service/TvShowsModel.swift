//
//  TvShowsModel.swift
//  MaxMovies
//
//  Created by Max zam on 09/03/2024.
//

import Foundation

struct TvShowsResponse: Codable, Equatable {
    var page: Int
    var results: [TvShow]
    var totalPages: Int
    
    enum CodingKeys: String, CodingKey {
        case page = "page"
        case results = "results"
        case totalPages = "total_pages"
    }
}

struct TvShow: Codable, Identifiable, Equatable, MediaDetails {
    
    // Computed property to make it conform to MediaDetails protocol
    var title: String {
        return name
    }
    
    var backDrop: String? {
        return backdropPath
    }
    
    var releaseDate: String? {
        return firstAirDate
    }
    
    let backdropPath: String?
    let firstAirDate: String?
    let genreIds: [Int]
    var genres: [String] = []
    let id: Int
    let name: String
    let originCountry: [String]
    let originalLanguage: String
    let originalName: String
    let overview: String
    let popularity: Double
    let posterPath: String?
    let voteAverage: Double
    let voteCount: Int
    
    enum CodingKeys: String, CodingKey {
        case backdropPath = "backdrop_path"
        case firstAirDate = "first_air_date"
        case genreIds = "genre_ids"
        case id, name
        case originCountry = "origin_country"
        case originalLanguage = "original_language"
        case originalName = "original_name"
        case overview, popularity
        case posterPath = "poster_path"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
}

enum TvGenre: String, CaseIterable {
    case all = "All Genres"
    case action = "Action & Adventure"
    case comedy
    case mystery
    case crime
    case drama
    case animation
    case documentary
    case family
    case news
    case kids
    case soap
    case scienceFiction = "Sci-Fi & Fantasy"
    case reality = "Reality"
    case war = "War & Politics"
    case western
    case talk
}

