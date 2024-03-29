//
//  TvShowsFeature.swift
//  MaxMovies
//
//  Created by Max zam on 09/03/2024.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct TvShowsFeature {
    @Dependency(\.networkService) var networkService
    
    @ObservableState
    struct State: Equatable {
        var isLoading: Bool = false
        var sortedCategory: TvShowCategory = .onTheAir
        var tvShowsResponse: MediaResponse = MediaResponse(page: 1, results: [], totalPages: 1, totalResults: 1)
        var isLoadingMore: Bool = false
        var currentPage: Int = 1
    }
    
    enum Action {
        case apiCall(TvShowCategory)
        case apiResponse(Result<MediaResponse, Error>)
        case showDetails(MediaItem)
        case requestMoreTvShows(TvShowCategory)
        case appendTvShowsResponse(Result<MediaResponse, Error>)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case .apiCall(let category):
                state.isLoading = true
                state.currentPage = 1
                state.sortedCategory = category
                return .run { [currentPage = state.currentPage] send in
                    let url = TmdbUrl.tvShow(category: category).getUrl(
                        queryItems: [URLQueryItem(name: "page", value: "\(currentPage)")])
                    do {
                        let tvShowsResponse: MediaResponse = try await networkService.fetch(url: url, headers: TmdbUrl.headers)
                        await send(.apiResponse(.success(tvShowsResponse)))
                    } catch {
                        await send(.apiResponse(.failure(error)))
                    }
                }
            case .apiResponse(let result):
                switch result {
                case .success(let tvShowsResponse):
                    state.tvShowsResponse = tvShowsResponse
                case .failure(let error):
                    print("error fetching tv shows: \(error)")
                }
                state.isLoading = false
                return .none
            case .showDetails(_):
                return .none
            case .requestMoreTvShows(let category):
                guard !state.isLoadingMore, state.currentPage < state.tvShowsResponse.totalPages else { return .none }
                state.isLoadingMore = true
                state.currentPage += 1
                return .run {[currentPage = state.currentPage] send in
                    let url = TmdbUrl.tvShow(category: category).getUrl(
                        queryItems: [URLQueryItem(name: "page", value: "\(currentPage)")])
                    do {
                        let movieResponse: MediaResponse = try await networkService.fetch(url: url, headers: TmdbUrl.headers)
                        await send(.appendTvShowsResponse(.success(movieResponse)))
                    } catch {
                        await send(.appendTvShowsResponse(.failure(error)))
                    }
                }
            case .appendTvShowsResponse(let result):
                switch result {
                case .success(let newTvShowsResponse):
                    let uniqueNewTvShows = newTvShowsResponse.results.filter { newItem in
                        !state.tvShowsResponse.results.contains { existingItem in
                            existingItem.id == newItem.id
                        }
                    }
                    state.tvShowsResponse.results.append(contentsOf: uniqueNewTvShows)
                    state.tvShowsResponse.page = newTvShowsResponse.page
                case .failure(let error):
                    print("Error fetching more tv shows: \(error)")
                }
                state.isLoadingMore = false
                return .none
            }
        }
    }
}
