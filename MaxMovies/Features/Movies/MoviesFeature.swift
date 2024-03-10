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
        var isLoadingMore: Bool = false
        var currentPage: Int = 1
    }
    
    enum Action {
        case apiCall(MovieCategory)
        case apiResponse(Result<MediaResponse, Error>)
        case showDetails(MediaItem)
        case requestMoreMovies(MovieCategory)
        case appendMoviesResponse(Result<MediaResponse, Error>)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .apiCall(let category):
                state.isLoading = true
                state.currentPage = 1 // Reset to first page
                state.sortedCategory = category
                return .run {[currentPage = state.currentPage] send in
                    let url = TmdbUrl.movie(category: category).getUrl(
                        queryItems: [URLQueryItem(name: "page", value: "\(currentPage)")])
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
                
            case .requestMoreMovies(let category):
                guard !state.isLoadingMore, state.currentPage < state.moviesResponse.totalPages else { return .none }
                state.isLoadingMore = true
                state.currentPage += 1
                return .run {[currentPage = state.currentPage] send in
                    let url = TmdbUrl.movie(category: category).getUrl(
                        queryItems: [URLQueryItem(name: "page", value: "\(currentPage)")])
                    do {
                        let movieResponse: MediaResponse = try await networkService.fetch(url: url, headers: TmdbUrl.headers)
                        await send(.appendMoviesResponse(.success(movieResponse)))
                    } catch {
                        await send(.appendMoviesResponse(.failure(error)))
                    }
                }
            case .appendMoviesResponse(let result):
                switch result {
                case .success(let newMoviesResponse):
                    let uniqueNewMovies = newMoviesResponse.results.filter { newItem in
                        !state.moviesResponse.results.contains { existingItem in
                            existingItem.id == newItem.id
                        }
                    }
                    state.moviesResponse.results.append(contentsOf: uniqueNewMovies)
                    state.moviesResponse.page = newMoviesResponse.page
                case .failure(let error):
                    print("Error fetching more movies: \(error)")
                }
                state.isLoadingMore = false
                return .none
            }
        }
    }
}

