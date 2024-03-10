//
//  VideoResponse.swift
//  MaxMovies
//
//  Created by Max zam on 09/03/2024.
//

import Foundation

struct VideoResponse: Codable, Identifiable, Equatable {
    let id: Int
    let results: [Video]
    
    struct Video: Codable, Identifiable, Equatable {
        let name: String
        let key: String
        let type: String
        let official: Bool
        
        var id: String {
            return key
        }
    }
}

extension VideoResponse.Video {
    var thumbnailURL: URL? {
        URL(string: "https://img.youtube.com/vi/\(key)/maxresdefault.jpg")
    }
}
