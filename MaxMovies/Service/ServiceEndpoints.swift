//
//  ServiceEndpoints.swift
//  MaxMovies
//
//  Created by Max zam on 09/03/2024.
//

import Foundation

enum TmdbUrl {
    case movie(category: MovieCategory)
    case movieGenres
    case movieReview(movieId: Int)
    case movieWatchProviders(movieId: Int)
    case movieTrailer(movieId: Int)
    case searchMovies
    case trendingMovies
    case tvShow (category: TvShowCategory)
    case tvGenres
    case tvReview(tvShowId: Int)
    case tvWatchProviders(tvShowId: Int)
    case tvShowTrailer(tvShowId: Int)
    case trendingTvShows
    case searchTvShows
    case searchMulti
    case trendingMulti
    case backDrop(backdropPath: String)
    
    var urlString: String {
        switch self {
        case .movie(let category):
            return "/3/movie/\(category.urlString)"
        case .movieGenres:
            return "/3/genre/movie/list"
        case .movieReview(let movieId):
            return "/3/movie/\(movieId)/reviews"
        case .movieWatchProviders(let movieId):
            return "/3/movie/\(movieId)/watch/providers"
        case .movieTrailer(let movieId):
            return "/3/movie/\(movieId)/videos"
        case .searchMovies:
            return "/3/search/movie"
        case .trendingMovies:
            return "/3/trending/movie/day"
        case .tvShow(category: let category):
            return "/3/tv/\(category.urlString)"
        case .tvGenres:
            return "/3/genre/tv/list"
        case .tvReview(tvShowId: let tvShowId):
            return "/3/tv/\(tvShowId)/reviews"
        case .tvWatchProviders(tvShowId: let tvShowId):
            return "/3/tv/\(tvShowId)/watch/providers"
        case .tvShowTrailer(tvShowId: let tvShowId):
            return "/3/tv/\(tvShowId)/videos"
        case .searchTvShows:
            return "/3/search/tv"
        case .trendingTvShows:
            return "/3/trending/tv/day"
        case .searchMulti:
            return "/3/search/multi"
        case .backDrop(backdropPath: let backdropPath):
            return "https://image.tmdb.org/t/p/w400/\(backdropPath)"
        case .trendingMulti:
            return "/3/trending/all/day"
        }
    }
    
    
    static var headers: [String: String] {
        var headers: [String: String] = ["accept": "application/json"]
        
        if let apiKey = getAPIKey() {
            headers["Authorization"] = "Bearer \(apiKey)"
        }
        
        return headers
    }
    
    func getUrl(queryItems: [URLQueryItem] = []) -> URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.themoviedb.org"
        urlComponents.path = self.urlString
        urlComponents.queryItems = queryItems
        
        return urlComponents.url
    }
}


enum MovieCategory: String, CaseIterable {
    case popular = "Popular"
    case topRated = "Top Rated"
    case nowPlaying = "Now playing"
    case upcoming = "Upcoming"
    
    var urlString: String {
        switch self {
        case .popular:
            return "popular"
        case .topRated:
            return "top_rated"
        case .nowPlaying:
            return "now_playing"
        case .upcoming:
            return "upcoming"
        }
    }
}

enum TvShowCategory: String, CaseIterable {
    case onTheAir = "On The Air"
    case popular = "Popular"
    case topRated = "Top Rated"
    
    var urlString: String {
        switch self {
        case .popular:
            return "popular"
        case .onTheAir:
            return "on_the_air"
        case .topRated:
            return "top_rated"
        }
    }
}

func getAPIKey() -> String? {
    var apiKey: String?
    
    if let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
       let xml = FileManager.default.contents(atPath: path) {
        do {
            if let plistData = try PropertyListSerialization.propertyList(from: xml, options: .mutableContainersAndLeaves, format: nil) as? [String: Any] {
                apiKey = plistData["Authorization"] as? String
            }
        } catch {
            print("Error reading plist: \(error)")
        }
    }
    return apiKey
}
