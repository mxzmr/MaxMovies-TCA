//
//  MoviesView.swift
//  MaxMovies
//
//  Created by Max zam on 09/03/2024.
//

import SwiftUI
import ComposableArchitecture

struct MoviesView: View {
    let store: StoreOf<MoviesFeature>
    let columnGrid = [GridItem(.flexible()),GridItem(.flexible())]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if store.isLoading {
                    VStack {
                        ProgressView()
                    }
                } else if store.moviesResponse.results.isEmpty {
                    Text("No movies found")
                } else {
                    LazyVGrid(columns: columnGrid, spacing: 5) {
                        ForEach(store.moviesResponse.results) { movie in
                            PosterTileView(posterPath: movie.posterPath)
                                .accessibilityLabel("Movie Poster: \(movie.title )")
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement:.automatic) {
                    Menu("Sort By") {
                        ForEach(MovieCategory.allCases, id: \.self) { category in
                            Button {
                                store.send(.apiCall(category))
                            } label: {
                                Text(category.rawValue)
                            }
                        }
                    }
                }
            }
            .onAppear {
                if store.moviesResponse.results.isEmpty {
                    store.send(.apiCall(.nowPlaying))
                }
            }
            .navigationTitle(store.sortedCategory.rawValue)
        }
    }
}

#Preview {
    MoviesView(store: Store(initialState: MoviesFeature.State(), reducer: {
        MoviesFeature()
    }))
}

