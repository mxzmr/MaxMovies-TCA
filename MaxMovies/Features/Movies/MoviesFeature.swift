//
//  MoviesFeature.swift
//  MaxMovies
//
//  Created by Max zam on 09/03/2024.
//
import SwiftUI
import ComposableArchitecture

@Reducer
struct MoviesFeature {
    @Dependency(\.networkService) var networkService
    
    @ObservableState
    struct State: Equatable {
        var isLoading: Bool = false
        var sortedCategory: MovieCategory = .popular
        var moviesResponse: MediaResponse = MediaResponse(page: 1, results: [], totalPages: 1, totalResults: 1)
    }
    
    enum Action {
        case apiCall(MovieCategory)
        case apiResponse(Result<MediaResponse, Error>)
        case showDetails(MediaItem)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .apiCall(let category):
                state.isLoading = true
                state.sortedCategory = category
                return .run { send in
                    let url = TmdbUrl.movie(category: category).getUrl(
                        queryItems: [URLQueryItem(name: "page", value: "\(1)")])
                    do {
                        let movieResponse: MediaResponse = try await networkService.fetch(url: url, headers: TmdbUrl.headers)
                        await send(.apiResponse(.success(movieResponse)))
                    } catch {
                        await send(.apiResponse(.failure(error)))
                    }
                }
            case .apiResponse(let result):
                switch result {
                case .success(let moviesResponse):
                    state.moviesResponse = moviesResponse
                case .failure(let error):
                    print("error fetching movies: \(error)")
                }
                state.isLoading = false
                return .none
            case .showDetails(_):
                return .none
            }
        }
    }
}

