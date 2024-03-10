//
//  URLForMediaItem.swift
//  MaxMovies
//
//  Created by Max zam on 10/03/2024.
//

import Foundation

func urlForMediaItem(withID id: Int) throws -> URL {
    let id = String(id)
    let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let favoritesFolderURL = documentsDirectoryURL.appendingPathComponent("favorites")
    
    // Ensure the 'favorites' folder exists
    if !FileManager.default.fileExists(atPath: favoritesFolderURL.path) {
        try FileManager.default.createDirectory(at: favoritesFolderURL, withIntermediateDirectories: true, attributes: nil)
    }
    
    let filename = "\(id).json"
    return favoritesFolderURL.appendingPathComponent(filename)
}
