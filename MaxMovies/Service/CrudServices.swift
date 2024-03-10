//
//  CrudServices.swift
//  MaxMovies
//
//  Created by Max zam on 10/03/2024.
//

import Foundation
import SwiftUI
import ComposableArchitecture

protocol JSONStorageProtocol {
    func saveJsonData<T: Encodable>(path: URL, dataToSave: T) throws
    func loadJsonData<T:Decodable> (path: URL) throws -> T?
    func deleteJsonData(at path: URL) throws
}

struct JSONStorageService: JSONStorageProtocol {
    func saveJsonData<T: Encodable>(path: URL, dataToSave: T) throws {
        let data = try JSONEncoder().encode(dataToSave)
        try data.write(to: path, options: [.atomicWrite, .completeFileProtection])
    }
    
    func loadJsonData<T:Decodable> (path: URL) throws -> T? {
        if FileManager.default.fileExists(atPath: path.path) {
            let data = try Data(contentsOf: path)
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            return decodedData
        }
        return nil
    }
    
    func deleteJsonData(at path: URL) throws {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path.path) {
            try fileManager.removeItem(at: path)
        } else {
            throw NSError(domain: "JSONStorageServiceError", code: 404, userInfo: [NSLocalizedDescriptionKey: "File does not exist at \(path)."])
        }
    }
}

extension FileManager {
    static func documentsDirectoryURL() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

private enum JSONStorageProtocolKey: DependencyKey {
    static let liveValue: JSONStorageProtocol = JSONStorageService()
}

extension DependencyValues {
    var JSONStorageService: JSONStorageProtocol {
        get { self[JSONStorageProtocolKey.self] }
        set { self[JSONStorageProtocolKey.self] = newValue }
    }
}
