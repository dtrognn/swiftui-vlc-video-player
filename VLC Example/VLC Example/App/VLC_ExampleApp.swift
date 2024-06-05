//
//  VLC_ExampleApp.swift
//  VLC Example
//
//  Created by dtrognn on 05/06/2024.
//

import SwiftUI

@main
struct VLC_ExampleApp: App {
    @StateObject private var router = Router()

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.navPath) {
                HomeView()
                    .navigationDestination(for: RouterDestination.self) { destination in
                        switch destination {
                        case .videoPlayer(let url):
                            VideoPlayerView(videoURL: url)
                        }
                    }
            }.environmentObject(router)
        }
    }
}
