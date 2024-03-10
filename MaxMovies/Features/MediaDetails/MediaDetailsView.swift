//
//  MediaDetailsView.swift
//  MaxMovies
//
//  Created by Max zam on 09/03/2024.
//

import SwiftUI
import ComposableArchitecture

struct MediaDetailsView: View {
    let store: StoreOf<MediaDetailsFeature>
    var body: some View {
        NavigationStack {
            ZStack {
                if let poster = store.media.posterPath {
                    AsyncImage(url: URL(string: TmdbUrl.backDrop(backdropPath: poster).urlString))  { state in
                        if let image = state.image {
                            image
                                .resizable()
                                .ignoresSafeArea()
                            
                        } else if state.error != nil {
                            VStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.gray)
                                Text("Image failed to load")
                                    .font(.caption)
                            }
                        }
                    }
                }
                ScrollView {
                    VStack(alignment: .leading) {
                        if let backDrop = (store.media.backDrop != nil) ? store.media.backDrop : store.media.posterPath {
                            AsyncImage(url: URL(string: TmdbUrl.backDrop(backdropPath: backDrop).urlString))  { state in
                                if let image = state.image {
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                    
                                } else if state.error != nil {
                                    VStack {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .foregroundColor(.gray)
                                        Text("Image failed to load")
                                            .font(.caption)
                                    }
                                } else {
                                    ColorChangingPlaceholderView(maxHeight: 400, aspectRatio: .fit)
                                }
                            }
                        }
                        Group {
                            HStack {
                                VStack(alignment: .leading) {
                                    if let title = store.media.title {
                                        Text(title)
                                            .font(.headline)
                                    }
                                    if let name = store.media.name {
                                        Text(name)
                                            .font(.headline)
                                    }
                                    if let releaseDate = store.media.releaseDate {
                                        Text("Release Date: \(releaseDate)")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    if let firstAirDate = store.media.firstAirDate {
                                        Text("First Air Date: \(firstAirDate)")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .padding(.vertical)
                                Spacer()
                                if let voteAverage = store.media.voteAverage, let voteCount = store.media.voteCount {
                                    VotesAverageAndOnlineReviewsView(votesAverage: voteAverage, votesCount: voteCount, handleMoreReviewsButton: {})
                                }
                            }
                            NavigationLink {
                                MediaDetailsVideosView(videos: store.trailers.results)
                            } label: {
                                Label("Videos", systemImage: "play")
                                    .frame(maxWidth: .infinity)
                            }
                            .modifier(AppButtonStyle(buttonColor: store.trailers.results.isEmpty ? .gray : .blue, foregroundColor: .white))
                            .disabled(store.trailers.results.isEmpty)
                            Text("Overview:")
                                .bold()
                                .padding(.vertical)
                            if let overview = store.media.overview {
                                ShowMoreTextView(overview)
                            }
                            
                            if let reviews = store.reviews.results {
                                ReviewsView(reviews: reviews)
                            }
                            
                        }
                        .padding(.horizontal)
                    }
                }
                .background(.thinMaterial)
                .onAppear {
                    store.send(.reviewsApiCall(store.media))
                    store.send(.trailersApiCall(store.media))
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        store.send(.delegate(.dismiss))
                    } label: {
                        Text("Done")
                            .bold()
                    }
                    
                }
            }
        }
    }
}

#Preview {
    MediaDetailsView(store: Store(initialState: MediaDetailsFeature.State(media: MediaItem.moc), reducer: {
        MediaDetailsFeature()
    }))
}



struct RatingView: View {
    @Binding var rating: Double
    
    var body: some View {
        HStack {
            Picker("picker", selection: $rating) {
                
                ForEach(1..<11) { index in
                    Label(String(index), systemImage: index <= Int(rating) ? "star.fill" : "star")
                        .onTapGesture {
                            rating = Double(index)
                        }
                }
            }
        }
    }
}


struct VotesAverageAndOnlineReviewsView: View {
    let votesAverage: Double
    let votesCount: Int
    let handleMoreReviewsButton: () -> Void
    
    var body: some View {
        Label(
            title: { Text(String(format: "%.1f", votesAverage)) },
            icon: { Text("⭐️").font(.system(size: 12)) }
        )
        Text("\(votesCount) Votes")
            .font(.caption)
            .foregroundStyle(.secondary)
    }
}

