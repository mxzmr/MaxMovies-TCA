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
        var trendingMediaResponse: MediaResponse = MediaResponse(page: 1, results: [], totalPages: 1, totalResults: 1)
        var popularMediaResponse: MediaResponse = MediaResponse(page: 1, results: [], totalPages: 1, totalResults: 1)
        var searchResponse: MediaResponse = MediaResponse(page: 1, results: [], totalPages: 1, totalResults: 1)
    }
    
    enum Action {
        case apiCall(ApiCallTerm, URLQueryItem? = nil)
        case apiResponse(Result<(ApiCallTerm, MediaResponse), Error>)
        case newSearchTerm(String)
        case callMultipleApiCalls
        case resetTextfield
        case showDetails(MediaItem)
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
                if !newSearchTerm.isEmpty {
                    // Cancel any existing debounce effect to start the timer over
                    return .send(.apiCall(.search, URLQueryItem(name: "query", value: "\(newSearchTerm)")))
                        .debounce(id: SearchDebounceID(), for: 0.5, scheduler: DispatchQueue.main)
                        .cancellable(id: SearchDebounceID(), cancelInFlight: true)
                }
                return .none
            case .callMultipleApiCalls:
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
            }
        }
    }
}

enum ApiCallTerm {
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
