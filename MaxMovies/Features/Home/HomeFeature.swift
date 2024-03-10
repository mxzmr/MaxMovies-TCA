//
//  HomeFeature.swift
//  MaxMovies
//
//  Created by Max zam on 09/03/2024.
//

import Foundation
import ComposableArchitecture

@Reducer
struct HomeFeature {
    @Dependency(\.networkService) var networkService
    
    @ObservableState
    struct State: Equatable {
        var isLoading: Bool = false
        var searchTerm: String = ""
        
        // Trending media
        var trendingMediaResponse: MediaResponse = MediaResponse(page: 1, results: [], totalPages: 1, totalResults: 1)
        var isLoadingMoreTrending: Bool = false
        var trendingMediaCurrentPage: Int = 1
        
        // Popular media
        var popularMediaResponse: MediaResponse = MediaResponse(page: 1, results: [], totalPages: 1, totalResults: 1)
        var isLoadingMorePopularMedia: Bool = false
        var popularMediaCurrentPage: Int = 1
        
        // Search
        var searchResponse: MediaResponse = MediaResponse(page: 1, results: [], totalPages: 1, totalResults: 1)
        var isLoadingMoreSearchResults: Bool = false
        var searchCurrentPage: Int = 1
    }
    
    enum Action {
        case apiCall(ApiEndpoint, URLQueryItem? = nil)
        case apiResponse(Result<(ApiEndpoint, MediaResponse), Error>)
        case newSearchTerm(String)
        case initiateMultipleApiRequests
        case resetTextfield
        case showDetails(MediaItem)
        case requestMoreData(ApiEndpoint, currentPage: Int, searchTerm: String? = nil)
        case requestMoreDataForPopular
        case appendDataResponse(ApiEndpoint, Result<MediaResponse, Error>)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .apiCall(apiCallTerm, queryItem):
                state.isLoading = true
                return .run { send in
                    let url = apiCallTerm.url.getUrl(
                        queryItems: [URLQueryItem(name: "page", value: "\(1)"), queryItem ?? URLQueryItem(name: "", value: "")])
                    do {
                        var mediaResponse: MediaResponse = try await networkService.fetch(url: url, headers: TmdbUrl.headers)
                        //Only include movies and tv shows
                        mediaResponse.results = mediaResponse.results.filter { $0.mediaType != "person" }
                        await send(.apiResponse(.success((apiCallTerm, mediaResponse))))
                    } catch {
                        await send(.apiResponse(.failure(error)))
                    }
                }
            case let .apiResponse(result):
                switch result {
                case let .success((apiCallTerm, mediaResponse)):
                    switch apiCallTerm {
                    case .search:
                        state.searchResponse = mediaResponse
                    case .trending:
                        state.trendingMediaResponse = mediaResponse
                    case .popularMovies, .popularTvShows:
                        state.popularMediaResponse.results.append(contentsOf: mediaResponse.results)
                    }
                case .failure(let error):
                    print("error fetching media: \(error)")
                }
                state.isLoading = false
                return .none
                
            case .newSearchTerm(let newSearchTerm):
                state.isLoading = true
                state.searchTerm = newSearchTerm
                state.searchCurrentPage = 1
                if !newSearchTerm.isEmpty {
                    return .send(.apiCall(.search, URLQueryItem(name: "query", value: "\(newSearchTerm)")))
                        .debounce(id: SearchDebounceID(), for: 0.6, scheduler: DispatchQueue.main)
                        .cancellable(id: SearchDebounceID(), cancelInFlight: true)
                }
                return .none
            case .initiateMultipleApiRequests:
                return .merge(
                    Effect<HomeFeature.Action>
                        .send(.apiCall(.trending, nil)),
                    Effect<HomeFeature.Action>
                        .send(.apiCall(.popularMovies, nil)),
                    Effect<HomeFeature.Action>
                        .send(.apiCall(.popularTvShows, nil))
                )
                
            case .resetTextfield:
                state.searchTerm = ""
                return .none
                
            case .showDetails(_):
                return .none
                
            case let .requestMoreData(endpoint, currentPage, searchTerm):
                let nextPage = currentPage + 1
                let url = endpoint.url.getUrl(queryItems: [URLQueryItem(name: "page", value: "\(nextPage)"), URLQueryItem(name: searchTerm != nil ? "query" : "", value: searchTerm ?? "")])
                
                return .run { send in
                    do {
                        let mediaResponse: MediaResponse = try await networkService.fetch(url: url, headers: TmdbUrl.headers)
                        await send(.appendDataResponse(endpoint, .success(mediaResponse)))
                    } catch {
                        await send(.appendDataResponse(endpoint, .failure(error)))
                    }
                }
                
            case let .appendDataResponse(endpoint, result):
                switch result {
                case .success(let newMediaResponse):
                    switch endpoint {
                    case .trending:
                        let uniqueNewTrending = newMediaResponse.results.filter { newItem in
                            !state.trendingMediaResponse.results.contains { existingItem in
                                existingItem.id == newItem.id
                            }
                        }
                        state.trendingMediaResponse.results.append(contentsOf: uniqueNewTrending)
                        state.trendingMediaResponse.page = newMediaResponse.page
                        state.trendingMediaCurrentPage += 1
                        
                    case .search:
                        let uniqueNewSearchResults = newMediaResponse.results.filter { newItem in
                            !state.searchResponse.results.contains { existingItem in
                                existingItem.id == newItem.id
                            }
                        }
                        state.searchResponse.results.append(contentsOf: uniqueNewSearchResults)
                        state.searchResponse.page = newMediaResponse.page
                        state.searchCurrentPage += 1
                        
                    case .popularMovies, .popularTvShows:
                        let uniqueNewPopularMedia = newMediaResponse.results.filter { newItem in
                            !state.popularMediaResponse.results.contains { existingItem in
                                existingItem.id == newItem.id
                            }
                        }
                        state.popularMediaResponse.results.append(contentsOf: uniqueNewPopularMedia)
                        state.popularMediaResponse.page = newMediaResponse.page
                        state.popularMediaCurrentPage += 1
                    }
                case .failure(let error):
                    print("Error fetching more data: \(error)")
                }
                return .none
                
            case .requestMoreDataForPopular:
                return .merge(
                    Effect<HomeFeature.Action>
                        .send(.requestMoreData(.popularMovies, currentPage: state.popularMediaCurrentPage)),
                    Effect<HomeFeature.Action>
                        .send(.requestMoreData(.popularTvShows, currentPage: state.popularMediaCurrentPage))
                )
            }
        }
    }
}

enum ApiEndpoint {
    case search
    case trending
    case popularMovies
    case popularTvShows
    
    var url: TmdbUrl {
        switch self {
        case .search:
            return .searchMulti
        case .trending:
            return .trendingMulti
        case .popularMovies:
            return .movie(category: .popular)
        case .popularTvShows:
            return .tvShow(category: .popular)
        }
    }
}

struct SearchDebounceID: Hashable {}
