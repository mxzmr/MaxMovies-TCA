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
    }
    
    enum Action {
        case movies(MoviesFeature.Action)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.movies, action: \.movies) {
            MoviesFeature()
        }
        
        Reduce { state, action in
            return .none
        }
    }
}
