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
    @ObservableState
    struct State: Equatable {
        var movies = MoviesFeature.State()
        var tvShows = TvShowsFeature.State()
        var home = HomeFeature.State()
        @Presents var mediaDetails: MediaDetailsFeature.State?
    }
    
    enum Action {
        case movies(MoviesFeature.Action)
        case tvShows(TvShowsFeature.Action)
        case home(HomeFeature.Action)
        case mediaDetails(PresentationAction<MediaDetailsFeature.Action>)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.movies, action: \.movies) {
            MoviesFeature()
        }
        Scope(state: \.tvShows, action: \.tvShows) {
            TvShowsFeature()
        }
        Scope(state: \.home, action: \.home) {
            HomeFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .movies(_):
                return .none
            case .tvShows(_):
                return .none
            case .home(.showDetails(let media)):
                state.mediaDetails = MediaDetailsFeature.State(media: media)
                return .none
            case .home(_):
                return .none
            case .mediaDetails(.presented(.delegate(.dismiss))):
                state.mediaDetails = nil
                return .none
            case .mediaDetails(_):
                return .none
            }
        }
        .ifLet(\.$mediaDetails, action: \.mediaDetails) {
            MediaDetailsFeature()
        }
    }
}
