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
            HomeView(store: store.scope(state: \.home, action: \.home))
                .tabItem {
                    Text("Home")
                }
            
            MoviesView(store: store.scope(state: \.movies, action: \.movies))
                .tabItem {
                    Text("Movies")
                }
            TvShowsView(store: store.scope(state: \.tvShows, action: \.tvShows))
                .tabItem {
                    Text("Tv Shows")
                }
            
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
