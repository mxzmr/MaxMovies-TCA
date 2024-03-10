//
//  HomeView.swift
//  MaxMovies
//
//  Created by Max zam on 09/03/2024.
//

import SwiftUI
import ComposableArchitecture

struct HomeView: View {
    @Bindable var store: StoreOf<HomeFeature>
    let columnGrid = [GridItem(.flexible()),GridItem(.flexible())]
    
    var body: some View {
        ScrollView {
            HStack {
                TextField("Search", text: $store.searchTerm.sending(\.newSearchTerm))
                Spacer()
                Button(action: {
                    store.send(.resetTextfield)
                }, label: {
                    Image(systemName: "xmark")
                })
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 25).fill(.ultraThinMaterial))
            if !store.searchTerm.isEmpty {
                ScrollView {
                    if store.isLoading {
                        VStack {
                            ProgressView()
                        }
                    } else if store.searchResponse.results.isEmpty {
                        Text("No results found, please try a different search.")
                    } else {
                        LazyVGrid(columns: columnGrid, spacing: 5) {
                            ForEach(store.searchResponse.results) { media in
                                PosterTileView(posterPath: media.posterPath)
                                    .onTapGesture {
                                        store.send(.showDetails(media))
                                    }
                            }
                        }
                    }
                }
            } else {
                VStack(alignment: .leading) {
                    Section(header: Text("Trending").font(.title2).padding(.horizontal)) {
                        ScrollView(.horizontal) {
                            LazyHStack {
                                ForEach(store.trendingMediaResponse.results) { media in
                                    PosterTileView(posterPath: media.posterPath)
                                        .onTapGesture {
                                            store.send(.showDetails(media))
                                        }
                                }
                            }
                            .padding(.bottom)
                        }
                        .scrollIndicators(.hidden)
                    }
                }
                .padding(.vertical)
                .background(Rectangle().fill(.ultraThinMaterial).shadow(radius: 1))
                
                VStack(alignment: .leading) {
                    Section(header: Text("popular").font(.title2).padding(.horizontal)) {
                        ScrollView(.horizontal) {
                            LazyHStack {
                                ForEach(store.popularMediaResponse.results) { media in
                                    PosterTileView(posterPath: media.posterPath)
                                        .onTapGesture {
                                            store.send(.showDetails(media))
                                        }
                                }
                            }
                            .padding(.bottom)
                        }
                        .scrollIndicators(.hidden)
                    }
                }
                .padding(.vertical)
                .background(Rectangle().fill(.ultraThinMaterial).shadow(radius: 1))
                
                
                
            }
        }
        .onAppear {
            if store.trendingMediaResponse.results.isEmpty || store.popularMediaResponse.results.isEmpty {
                store.send(.callMultipleApiCalls)
            }
        }
    }
}

#Preview {
    HomeView(store: Store(initialState: HomeFeature.State(), reducer: {
        HomeFeature()
    }))
}
