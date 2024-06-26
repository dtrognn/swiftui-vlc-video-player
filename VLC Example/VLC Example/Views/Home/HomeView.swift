//
//  ContentView.swift
//  VLC Example
//
//  Created by dtrognn on 05/06/2024.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var router: Router
    @StateObject private var vm = HomeViewModel()

    var body: some View {
        ZStack {
            AppStyle.theme.backgroundColor.ignoresSafeArea()

            VStack(spacing: AppStyle.layout.standardSpace) {
                title

                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: AppStyle.layout.standardSpace) {
                        ForEach(vm.category.videos) { video in
                            VideoItemView(video: video) { videoSelected in
                                if let url = videoSelected.sources.first {
                                    router.navigate(to: RouterDestination.videoPlayer(url))
                                }
                            }
                        }
                    }.padding(.horizontal, AppStyle.layout.standardSpace)
                }
            }
        }
    }
}

private extension HomeView {
    var title: some View {
        return Text("Movies")
            .font(AppStyle.font.medium20)
            .foregroundColor(AppStyle.theme.textNormalColor)
    }
}

#Preview {
    HomeView()
}
