//
//  MediaDetailsVideoView.swift
//  MaxMovies
//
//  Created by Max zam on 09/03/2024.
//

import SwiftUI

struct MediaDetailsVideosView: View {
    @State var isLoading = true
    @State var newTrailer = ""
    let videos: [VideoResponse.Video]
    
    var body: some View {
        ScrollView {
            ForEach(videos) { video in
                NavigationLink {
                    ScrollView {
                        ZStack {
                            YoutubeVideoView(youtubeVideoKey: newTrailer, enableAutoplay: true, onLoadingComplete: {
                                isLoading = false
                            })
                            if isLoading {
                                ColorChangingPlaceholderView(width: 400, height: 300, aspectRatio: .fill)
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 300, maxHeight: 500)
                        .onAppear {
                            newTrailer = video.key
                        }
                        Divider()
                        ForEach(videos) { video in
                            Button(action: {
                                newTrailer = video.key
                            }, label: {
                                YoutubeThumbnailView(video: video)
                            })
                        }
                    }
                } label: {
                    YoutubeThumbnailView(video: video)
                }  
            }
        }
        .onDisappear {
            isLoading = true
        }
    }
}

#Preview {
    NavigationStack {
        MediaDetailsVideosView(videos:[VideoResponse.Video(name: "Trailer", key: "wedfds", type: "video", official: false)])
    }
}
