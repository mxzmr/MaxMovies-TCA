//
//  AppTabView.swift
//  MaxMovies
//
//  Created by Max zam on 09/03/2024.
//

import SwiftUI
import ComposableArchitecture

struct AppTabView: View {
    @Bindable var store: StoreOf<AppFeature>
    
    var body: some View {
        TabView {
            HomeView(store: store.scope(state: \.homeFeature, action: \.homeFeature))
                .tabItem {
                    VStack {
                        Image(systemName: "house")
                        Text("Home")
                    }
                }
            
            MoviesView(store: store.scope(state: \.moviesFeature, action: \.moviesFeature))
                .tabItem {
                    VStack {
                        Image(systemName: "popcorn.fill")
                        Text("Movies")
                    }
                }
            TvShowsView(store: store.scope(state: \.tvShowsFeature, action: \.tvShowsFeature))
                .tabItem {
                    VStack {
                        Image(systemName: "tv")
                        Text("Tv Shows")
                    }
                }
            
            FavoritesView(store: store.scope(state: \.favoritesFeature, action: \.favoritesFeature))
                .tabItem {
                    VStack {
                        Image(systemName: "bookmark.fill")
                        Text("Favorites")
                    }
                }
        }
        .onAppear {
            store.send(.loadFavorites)
        }
        .sheet(item: $store.scope(state: \.mediaDetails, action: \.mediaDetails)) { mediaStore in
            MediaDetailsView(store: mediaStore)
        }
    }
}

#Preview {
    AppTabView(store: Store(initialState: AppFeature.State(), reducer: {
        AppFeature()
    }))
}
