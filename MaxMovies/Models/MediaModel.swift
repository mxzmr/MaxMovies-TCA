//
//  MediaModel.swift
//  MaxMovies
//
//  Created by Max zam on 09/03/2024.
//

import Foundation

struct MediaResponse: Codable, Equatable {
    
    let page: Int
    var results: [MediaItem]
    let totalPages: Int
    let totalResults: Int
    
    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

// Individual movie or TV show
struct MediaItem: Codable, Identifiable, Equatable {
    let adult: Bool
    let backdropPath: String?
    let id: Int
    let title: String?
    let originalLanguage: String?
    let originalTitle: String?
    let overview: String?
    let posterPath: String?
    let backDrop: String?
    let mediaType: String?
    let genreIds: [Int]?
    let popularity: Double?
    let releaseDate: String?
    let video: Bool?
    let voteAverage: Double?
    let voteCount: Int?
    let name: String?
    let originalName: String?
    let firstAirDate: String?
    let originCountry: [String]?
    
    
    enum CodingKeys: String, CodingKey {
        case adult
        case backdropPath = "backdrop_path"
        case id
        case title
        case originalLanguage = "original_language"
        case originalTitle = "original_title"
        case overview
        case posterPath = "poster_path"
        case mediaType = "media_type"
        case genreIds = "genre_ids"
        case popularity
        case releaseDate = "release_date"
        case video
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case name
        case originalName = "original_name"
        case firstAirDate = "first_air_date"
        case originCountry = "origin_country"
        case backDrop
    }
    
    static let moc = MediaItem(adult: false, backdropPath: "", id: 1, title: "Greatest movie ever", originalLanguage: nil, originalTitle: nil, overview: "some greate movie here about great stuff", posterPath: nil, backDrop: nil, mediaType: "movie", genreIds: nil, popularity: nil, releaseDate: nil, video: nil, voteAverage: nil, voteCount: nil, name: nil, originalName: nil, firstAirDate: nil, originCountry: nil)
}

