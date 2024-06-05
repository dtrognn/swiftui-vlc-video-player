//
//  ContentView.swift
//  VLC Example
//
//  Created by dtrognn on 05/06/2024.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var vm = HomeViewModel()

    var body: some View {
        VStack {
            LazyVStack {
                ForEach(vm.category.videos) { video in
                    Text(video.title)
                }
            }
        }
        .padding()
    }
}

#Preview {
    HomeView()
}
