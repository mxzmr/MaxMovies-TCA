//
//  AppTabView.swift
//  MaxMovies
//
//  Created by Max zam on 09/03/2024.
//

import SwiftUI
import ComposableArchitecture

struct AppTabView: View {
    let store: StoreOf<AppFeature>
    
    var body: some View {
        TabView {
            MoviesView(store: store.scope(state: \.movies, action: \.movies))
                .tabItem {
                    Text("Movies")
                }
        }
    }
}

#Preview {
    AppTabView(store: Store(initialState: AppFeature.State(), reducer: {
        AppFeature()
    }))
}
