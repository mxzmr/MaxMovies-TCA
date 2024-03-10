//
//  MediaDetailsView.swift
//  MaxMovies
//
//  Created by Max zam on 09/03/2024.
//

import Foundation
import ComposableArchitecture

@Reducer
struct MediaDetailsFeature {
    @Dependency(\.networkService) var networkService
    
    @ObservableState
    struct State: Equatable {
        var media: MediaItem
        var reviews: ReviewsResponse = ReviewsResponse(id: 1, page: 1, results: [], totalPages: 1)
        var trailers: VideoResponse = VideoResponse(id: 1, results: [])
        var isFavorite: Bool = false
    }
    
    enum Action {
        case reviewsApiCall(MediaItem)
        case apiReviewResponse(Result<ReviewsResponse, Error>)
        case trailersApiCall(MediaItem)
        case apitrailersResponse(Result<VideoResponse, Error>)
        case delegate(Delegate)
        
        enum Delegate {
            case dismiss
            case save(MediaItem)
            case remove(MediaItem)
        }
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .reviewsApiCall(let mediaItem):
                return .run { send in
                    // Check if its a movie or tv show, only tv shows have first air date
                    let tmdbUrl = mediaItem.firstAirDate?.isEmpty == nil ? TmdbUrl.movieReview(movieId: mediaItem.id) : TmdbUrl.tvReview(tvShowId: mediaItem.id)
                    let url = tmdbUrl.getUrl(
                        queryItems: [URLQueryItem(name: "page", value: "\(1)")])
                    do {
                        let reviewsResponse: ReviewsResponse = try await networkService.fetch(url: url, headers: TmdbUrl.headers)
                        await send(.apiReviewResponse(.success(reviewsResponse)))
                    } catch {
                        await send(.apiReviewResponse(.failure(error)))
                    }
                }
            case .apiReviewResponse(let result):
                switch result {
                case .success(let reviews):
                    state.reviews = reviews
                case .failure(let error):
                    print("Error fetching reivews: \(error)")
                }
                return .none
            case .trailersApiCall(let mediaItem):
                return .run { send in
                    // Check if its a movie or tv show, only tv shows have first air date
                    let tmdbUrl = mediaItem.firstAirDate?.isEmpty == nil ? TmdbUrl.movieTrailer(movieId: mediaItem.id) : TmdbUrl.tvShowTrailer(tvShowId: mediaItem.id)
                    let url = tmdbUrl.getUrl(
                        queryItems: [URLQueryItem(name: "page", value: "\(1)")])
                    do {
                        let videoResponse: VideoResponse = try await networkService.fetch(url: url, headers: TmdbUrl.headers)
                        await send(.apitrailersResponse(.success(videoResponse)))
                    } catch {
                        await send(.apitrailersResponse(.failure(error)))
                    }
                }
            case .apitrailersResponse(let result):
                switch result {
                case .success(let trailers):
                    state.trailers = trailers
                case .failure(let error):
                    print("Error fetching trailers: \(error)")
                }
                return .none
            case .delegate(.save(_)), .delegate(.remove(_)):
                state.isFavorite.toggle()
                return .none
            case .delegate(_):
                return .none
            }
        }
    }
}
