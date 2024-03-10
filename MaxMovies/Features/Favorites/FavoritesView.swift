//
//  FavoritesView.swift
//  MaxMovies
//
//  Created by Max zam on 10/03/2024.
//

import SwiftUI
import ComposableArchitecture

struct FavoritesView: View {
    let store: StoreOf<FavoritesFeature>
    let columnGrid = [GridItem(.flexible()),GridItem(.flexible())]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if store.favorites.isEmpty {
                    Text("No favorites found")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    LazyVGrid(columns: columnGrid, spacing: 0) {
                        ForEach(store.favorites, id: \.id) { mediaItem in
                            PosterTileView(posterPath: mediaItem.posterPath)
                                .onTapGesture {
                                    store.send(.showDetails(mediaItem))
                                }
                        }
                    }
                }
            }
            .navigationTitle("Favorites")
            Spacer()
        }
    }
}


#Preview {
    FavoritesView(store: Store(initialState: FavoritesFeature.State(), reducer: {
        FavoritesFeature()
    }))
}
