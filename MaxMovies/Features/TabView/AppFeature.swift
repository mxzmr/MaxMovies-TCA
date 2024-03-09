//
//  AppFeature.swift
//  MaxMovies
//
//  Created by Max zam on 09/03/2024.
//

import Foundation
import ComposableArchitecture

@Reducer
struct AppFeature {
    struct State: Equatable {
        var movies = MoviesFeature.State()
        var tvShows = TvShowsFeature.State()
    }
    
    enum Action {
        case movies(MoviesFeature.Action)
        case tvShows(TvShowsFeature.Action)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.movies, action: \.movies) {
            MoviesFeature()
        }
        Scope(state: \.tvShows, action: \.tvShows) {
            TvShowsFeature()
        }
        
        Reduce { state, action in
            return .none
        }
    }
}
