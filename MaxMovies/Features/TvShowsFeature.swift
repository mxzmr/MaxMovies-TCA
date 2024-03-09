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
        var tvShowsResponse: TvShowsResponse = TvShowsResponse(page: 1, results: [], totalPages: 1)
    }
    
    enum Action {
        case apiCall(TvShowCategory)
        case apiResponse(Result<TvShowsResponse, Error>)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case .apiCall(let category):
                state.isLoading = true
                state.sortedCategory = category
                return .run { send in
                    let url = TmdbUrl.tvShow(category: category).getUrl(
                        queryItems: [URLQueryItem(name: "page", value: "\(1)")])
                    do {
                        let tvShowsResponse: TvShowsResponse = try await networkService.fetch(url: url, headers: TmdbUrl.headers)
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
                    //Show empty state if there is an error
                    state.tvShowsResponse.results = []
                    print("error fetching tv shows: \(error)")
                }
                state.isLoading = false
                return .none
            }
        }
    }
}
