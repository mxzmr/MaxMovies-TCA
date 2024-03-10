//
//  TvShowsView.swift
//  MaxMovies
//
//  Created by Max zam on 09/03/2024.
//

import SwiftUI
import ComposableArchitecture

struct TvShowsView: View {
    let store: StoreOf<TvShowsFeature>
    let columnGrid = [GridItem(.flexible()),GridItem(.flexible())]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if store.isLoading {
                    VStack {
                        ProgressView()
                    }
                } else if store.tvShowsResponse.results.isEmpty {
                    Text("No tv shows found")
                } else {
                    LazyVGrid(columns: columnGrid, spacing: 5) {
                        ForEach(store.tvShowsResponse.results) { show in
                            PosterTileView(posterPath: show.posterPath)
                                .onTapGesture {
                                    store.send(.showDetails(show))
                                }
                                .onAppear {
                                    if let lastTvShow = store.tvShowsResponse.results.last, lastTvShow == show {
                                        store.send(.requestMoreTvShows(store.sortedCategory))
                                    }
                                }
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement:.automatic) {
                    Menu("Sort By") {
                        ForEach(TvShowCategory.allCases, id: \.self) { category in
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
                if store.tvShowsResponse.results.isEmpty {
                    store.send(.apiCall(.onTheAir))
                }
            }
            .navigationTitle(store.sortedCategory.rawValue)
        }
    }
}

#Preview {
    TvShowsView(store: Store(initialState: TvShowsFeature.State(), reducer: {
        TvShowsFeature()
    }))
}
