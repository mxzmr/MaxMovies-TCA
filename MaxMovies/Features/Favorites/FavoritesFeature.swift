//
//  FavoritesFeature.swift
//  MaxMovies
//
//  Created by Max zam on 10/03/2024.
//

import Foundation
import ComposableArchitecture

@Reducer
struct FavoritesFeature {
    @Dependency(\.JSONStorageService) var jsonStorageService
    
    @ObservableState
    struct State: Equatable {
        var favorites: IdentifiedArrayOf<MediaItem> = []
    }
    
    enum Action {
        case loadFavorites(IdentifiedArrayOf<MediaItem>)
        case showDetails(MediaItem)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .showDetails(_):
                return .none
            case .loadFavorites(let favorites):
                state.favorites = favorites
                return .none
            }
        }
    }
}
