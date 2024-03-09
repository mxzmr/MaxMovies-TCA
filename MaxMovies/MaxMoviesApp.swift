//
//  MaxMoviesApp.swift
//  MaxMovies
//
//  Created by Max zam on 09/03/2024.
//

import SwiftUI
import ComposableArchitecture

@main
struct MaxMoviesApp: App {
    static let store = Store(initialState: AppFeature.State()) {
        AppFeature()
    }
    var body: some Scene {
        WindowGroup {
            AppTabView(store: MaxMoviesApp.store)
        }
    }
}
