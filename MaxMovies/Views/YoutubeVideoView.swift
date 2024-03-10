//
//  YoutubeVideoView.swift
//  MaxMovies
//
//  Created by Max zam on 09/03/2024.
//

import SwiftUI
import WebKit

struct YoutubeVideoView: UIViewRepresentable {
    
    var youtubeVideoKey: String
    let enableAutoplay: Bool
    var onLoadingComplete: () -> Void  // Completion handler

    func makeUIView(context: Context) -> WKWebView {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsInlineMediaPlayback = true
        webConfiguration.mediaTypesRequiringUserActionForPlayback = []

        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let path = formattedURL()
        if uiView.url?.absoluteString != path {
            guard let url = URL(string: path) else { return }
            uiView.scrollView.isScrollEnabled = false
            uiView.load(URLRequest(url: url))
        }
    }
    
    private func formattedURL() -> String {
        "https://www.youtube.com/embed/\(youtubeVideoKey)?\(enableAutoplay ? "autoplay=1&mute=1&" : "")playsinline=1"
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: YoutubeVideoView
        
        init(parent: YoutubeVideoView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.onLoadingComplete() // Notify when loading is complete
        }
    }
}

