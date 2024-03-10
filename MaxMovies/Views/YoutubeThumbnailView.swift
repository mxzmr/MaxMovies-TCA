//
//  YoutubeThumbnailView.swift
//  MaxMovies
//
//  Created by Max zam on 09/03/2024.
//

import SwiftUI

struct YoutubeThumbnailView: View {
    @State var isImageAvailable = true
    let video: VideoResponse.Video
    
    var body: some View {
        HStack {
            if let url = video.thumbnailURL {
                ZStack {
                    AsyncImage(url: url) { state in
                        if let image = state.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 150, height: 100)
                                .onAppear {
                                    isImageAvailable = true
                                }
                        } else if state.error != nil {
                            // handle error
                            ZStack {
                                Image(systemName: "photo")
                                    .resizable()
                                    .frame(width: 150, height: 100)
//                                    .cornerRadius(8)
                                Image(systemName: "line.diagonal")
                                    .resizable()
                                    .frame(width: 140, height: 100)
                                    .foregroundStyle(.primary)
                            }
                        } else {
                            ColorChangingPlaceholderView(width: 150, height: 100, aspectRatio: .fit)
                        }
                    }
                    Image(systemName: "play")
                        .foregroundStyle(.primary)
                }
            }
            else {
                // Placeholder in case there is no URL
                Image(systemName: "photo")
                    .resizable()
                    .frame(width: 150, height: 100)
            }
            Spacer()
            if isImageAvailable {
                VStack(alignment: .leading) {
                    Text(video.type)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(video.name)
                        .font(.headline)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                .padding(.horizontal)
                Spacer()
            }
        }
    }
}


#Preview {
    YoutubeThumbnailView(video: VideoResponse.Video(name: "trailer", key: "wdfs3", type: "clip", official: false))
}

