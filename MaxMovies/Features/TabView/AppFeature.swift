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
    @Dependency(\.JSONStorageService) var jsonStorageService
    
    @ObservableState
    struct State: Equatable {
        var moviesFeature = MoviesFeature.State()
        var tvShowsFeature = TvShowsFeature.State()
        var homeFeature = HomeFeature.State()
        var favoritesFeature = FavoritesFeature.State()
        var favoriteMedia: IdentifiedArrayOf<MediaItem> = []
        @Presents var mediaDetails: MediaDetailsFeature.State?
    }
    
    enum Action {
        case moviesFeature(MoviesFeature.Action)
        case tvShowsFeature(TvShowsFeature.Action)
        case homeFeature(HomeFeature.Action)
        case favoritesFeature(FavoritesFeature.Action)
        case mediaDetails(PresentationAction<MediaDetailsFeature.Action>)
        case loadFavorites
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.moviesFeature, action: \.moviesFeature) {
            MoviesFeature()
        }
        Scope(state: \.tvShowsFeature, action: \.tvShowsFeature) {
            TvShowsFeature()
        }
        Scope(state: \.homeFeature, action: \.homeFeature) {
            HomeFeature()
        }
        Scope(state: \.favoritesFeature, action: \.favoritesFeature) {
            FavoritesFeature()
        }
        
        
        Reduce { state, action in
            switch action {
            case .moviesFeature(.showDetails(let media)):
                state.mediaDetails = MediaDetailsFeature.State(media: media, isFavorite: state.favoriteMedia.contains(media))
                return .none
            case .moviesFeature(_):
                return .none
            case .tvShowsFeature(.showDetails(let media)):
                state.mediaDetails = MediaDetailsFeature.State(media: media, isFavorite: state.favoriteMedia.contains(media))
                return .none
            case .tvShowsFeature(_):
                return .none
            case .homeFeature(.showDetails(let media)):
                state.mediaDetails = MediaDetailsFeature.State(media: media, isFavorite: state.favoriteMedia.contains(media))
                return .none
            case .homeFeature(_):
                return .none
            case .favoritesFeature(.showDetails(let media)):
                state.mediaDetails = MediaDetailsFeature.State(media: media, isFavorite: state.favoriteMedia.contains(media))
                return .none
            case .favoritesFeature(_):
                return .none
            case .mediaDetails(.presented(.delegate(.dismiss))):
                state.mediaDetails = nil
                return .none
            case .mediaDetails(.presented(.delegate(.save(let mediaItem)))):
                state.favoriteMedia.append(mediaItem)
                return .run {[favorites = state.favoriteMedia] send in
                    do {
                        let mediaURL = try urlForMediaItem(withID: mediaItem.id)
                        try jsonStorageService.saveJsonData(path: mediaURL, dataToSave: mediaItem)
                        await send(.favoritesFeature(.loadFavorites(favorites)))
                    } catch {
                        print("Error creating 'favorites' directory or saving favorites: \(error)")
                    }
                }
                
            case .mediaDetails(.presented(.delegate(.remove(let mediaItem)))):
                state.favoriteMedia.remove(mediaItem)
                return .run {[favorites = state.favoriteMedia] send in
                    do {
                        let mediaURL = try urlForMediaItem(withID: mediaItem.id)
                        try jsonStorageService.deleteJsonData(at: mediaURL)
                        await send(.favoritesFeature(.loadFavorites(favorites)))
                    } catch {
                        print("Error deleting media item :\(error)")
                    }
                }
                
            case .mediaDetails(_):
                return .none
                
            case .loadFavorites:
                let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let favoritesFolderURL = documentsDirectoryURL.appendingPathComponent("favorites")
                do {
                    let fileURLs = try FileManager.default.contentsOfDirectory(at: favoritesFolderURL, includingPropertiesForKeys: nil)
                    let jsonFiles = fileURLs.filter { $0.pathExtension == "json" }
                    var favorites = [MediaItem]()
                    for fileURL in jsonFiles {
                        do {
                            if let favorite: MediaItem = try jsonStorageService.loadJsonData(path: fileURL) {
                                favorites.append(favorite)
                            }
                        } catch {
                            print("Error loading JSON from \(fileURL): \(error)")
                        }
                    }
                    state.favoriteMedia = IdentifiedArrayOf<MediaItem>(uniqueElements: favorites)
                    return .send(.favoritesFeature(.loadFavorites(state.favoriteMedia)))
                } catch {
                    print("Error listing files in favorites directory: \(error)")
                }
                return .none
            }
        }
        .ifLet(\.$mediaDetails, action: \.mediaDetails) {
            MediaDetailsFeature()
        }
    }
}

