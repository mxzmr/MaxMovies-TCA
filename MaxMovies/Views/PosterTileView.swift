//
//  PosterTileView.swift
//  MaxMovies
//
//  Created by Max zam on 09/03/2024.
//

import SwiftUI

struct PosterTileView: View {
    let posterPath: String?
    
    var body: some View {
        if let posterPath {
            AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w200/\(posterPath)")) { Image in
                Image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                ColorChangingPlaceholderView(width: 200, height: 300, aspectRatio: .fit)
            }
        }
    }
}

#Preview {
    PosterTileView(posterPath: "")
}
