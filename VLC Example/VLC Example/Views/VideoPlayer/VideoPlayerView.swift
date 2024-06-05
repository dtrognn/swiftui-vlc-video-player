//
//  VideoPlayerView.swift
//  VLC Example
//
//  Created by dtrognn on 05/06/2024.
//

import SwiftUI

struct VideoPlayerView: View {
    private var videoURL: String

    @StateObject private var videoVM = CommonVideoPlayerViewModel()
    @State private var showSkeletonAnimation: Bool = false
    @State private var showLoadingView: Bool = false
    @State private var showErrorView: Bool = false
    @State private var showControlView: Bool = false

    @State private var isPlaying: Bool = false
    @State private var currentTimeSecond: Double = 0
    @State private var currentTimeString: String = "00:00"
    @State private var totalTimeString: String = "00:00"
    @State private var totalTimeSecond: Double = 0

    private let didBecomeActiveNotification = NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
    private let didEnterBackgroundNotification = NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
    private let numberOfSecondInMinute: Int = 60
    private let numberOfSecondInHour: Int = 60 * 60
    private let numberOfSecondInDay: Int = 24 * 60 * 60

    init(videoURL: String) {
        self.videoURL = videoURL
    }

    var body: some View {
        CommonVideoPlayerView(vm: videoVM)
            .overlay(showLoadingView ? loadingView.asAnyView : EmptyView().asAnyView)
            .overlay(showErrorView ? errorView.asAnyView : EmptyView().asAnyView)
            .overlay(showControlView ? controlView.asAnyView : EmptyView().asAnyView)
            .onTapGesture {
                showControl()
            }
            .ignoresSafeArea()
//            .navigationBarBackButtonHidden()
            .onAppear {
                videoVM.loadURL(videoURL)
            }.onDisappear {
                stop()
            }.onReceive(didBecomeActiveNotification) { _ in
                play()
            }.onReceive(didEnterBackgroundNotification) { _ in
                pause()
            }.onReceive(videoVM.$mediaPlayerState) { state in
                handleVideoState(state)
            }.onReceive(videoVM.onUpdateTotalTime) { totalString, totalSecond in
                self.totalTimeString = totalString
                self.totalTimeSecond = totalSecond
            }.onReceive(videoVM.onUpdateCurrentTime) { currentTime in
                self.currentTimeSecond = Double(currentTime)
                self.formatCurrentTime(currentTime)
            }
    }
}

private extension VideoPlayerView {
    func handleVideoState(_ state: MediaPlayerState) {
        switch state {
        case .error:
            showLoadingView = false
            showErrorView = true
        case .openning:
            showErrorView = false
            showLoadingView = true
        default: break
        }
    }

    func formatCurrentTime(_ currentTime: Int) {
        let hours = (currentTime % numberOfSecondInDay) / numberOfSecondInHour
        let minutes = (currentTime % numberOfSecondInHour) / numberOfSecondInMinute
        let seconds = (currentTime % numberOfSecondInMinute)

        switch currentTime {
        case 0 ..< numberOfSecondInHour:
            currentTimeString = String(format: "%2d:%02d", minutes, seconds)
        default:
            currentTimeString = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
    }

    func showControl() {
        withAnimation(.easeInOut(duration: 0.3).speed(0.01)) {
            showControlView = true
        }
        hideControl()
    }

    func hideControl() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation(.easeInOut(duration: 0.3).speed(0.01)) {
                showControlView = false
            }
        }
    }

    func handleToggleScreen() {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }),
              let windowScene = window.windowScene else { return }

        if windowScene.interfaceOrientation == .portrait {
            windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .landscapeRight)) { error in
                print("AAA landscape error: \(error.localizedDescription)")
            }
        } else {
            windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait)) { error in
                print("AAA landscape error: \(error.localizedDescription)")
            }
        }
    }

    func play() {
        videoVM.play()
    }

    func pause() {
        videoVM.pause()
    }

    func stop() {
        videoVM.stop()
    }
}

// MARK: - Control view

private extension VideoPlayerView {
    var controlView: some View {
        return ZStack {
            controlBackgroundView

            VStack {
                Spacer()
                HStack(spacing: AppStyle.layout.hugeSpace) {
                    backwardButton
                    playPauseButton
                    forwardButton
                }
                Spacer()
                timeView
            }
        }
    }

    var playPauseButton: some View {
        return Button {
            isPlaying ? pause() : play()
        } label: {
            Image(isPlaying ? "ic_pause" : "ic_play")
                .applyTheme(.white)
        }.onReceive(videoVM.$isPlaying) { isPlaying in
            self.isPlaying = isPlaying
        }
    }

    var backwardButton: some View {
        return Button {
            videoVM.backward()
        } label: {
            Image("ic_back_ward").applyTheme(.white)
        }
    }

    var forwardButton: some View {
        return Button {
            videoVM.forward()
        } label: {
            Image("ic_forward").applyTheme(.white)
        }
    }

    var fullscreenButton: some View {
        return Button {
            handleToggleScreen()
        } label: {
            Image("ic_full_screen")
                .padding(.all, AppStyle.layout.smallSpace)
        }
    }

    var controlBackgroundView: some View {
        return ZStack {
            Color.clear

            LinearGradient(gradient: .init(colors: [.black.opacity(0.3), .clear, .clear, .black.opacity(0.5)]), startPoint: .top, endPoint: .bottom)
                .clipped()
        }
    }
}

// MARK: - Slider view

private extension VideoPlayerView {
    var timeView: some View {
        return VStack(alignment: .leading, spacing: AppStyle.layout.mediumSpace) {
            Text(String(format: "%@/%@", currentTimeString, totalTimeString))
                .font(AppStyle.font.regular14)
                .foregroundColor(.white)

            HStack(spacing: AppStyle.layout.mediumSpace) {
                sliderView
                fullscreenButton
            }
        }.padding(.horizontal, AppStyle.layout.mediumSpace)
            .padding(.bottom, AppStyle.layout.largeSpace)
    }

    var sliderView: some View {
        return Slider(value: $currentTimeSecond, in: 0 ... totalTimeSecond, onEditingChanged: { isEditing in
            if !isEditing {
                videoVM.setCurrentTime(currentTimeSecond)
            }
        }).tint(.white)
            .onAppear {
                let progressCircleConfig = UIImage.SymbolConfiguration(scale: .small)
                UISlider.appearance()
                    .setThumbImage(UIImage(systemName: "circle.fill",
                                           withConfiguration: progressCircleConfig), for: .normal)
            }
    }
}

// MARK: - Loading view

private extension VideoPlayerView {
    var loadingView: some View {
        return ZStack {
            cardSkeletonView

            VStack(spacing: AppStyle.layout.standardSpace) {
                ProgressView().scaleEffect(1.5)
                loadingSkeletonText
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                withAnimation(Animation.default.speed(0.15).delay(0).repeatForever(autoreverses: false)) {
                    showSkeletonAnimation.toggle()
                }
            }.onReceive(videoVM.onVideoStartPlaying) { _ in
                withAnimation(.bouncy) { showLoadingView = false }
            }
    }

    var cardSkeletonView: some View {
        let center = (UIScreen.main.bounds.size.width / 2)
        return ZStack {
            Color.gray.opacity(0.7)

            Color.white
                .mask(
                    Rectangle()
                        .fill(LinearGradient(gradient: .init(colors: [.clear, .white.opacity(0.48), .clear]), startPoint: .top, endPoint: .bottom))
                        .rotationEffect(.init(degrees: 20))
                        .offset(x: showSkeletonAnimation ? 3 * center : -center * 3)
                )
        }
    }

    var loadingSkeletonText: some View {
        return ZStack {
            Text("Loading..")
                .font(AppStyle.font.semibold18)
                .foregroundColor(AppStyle.theme.iconColor.opacity(0.3))

            Text("Loading..")
                .font(AppStyle.font.semibold18)
                .foregroundColor(AppStyle.theme.iconColor)
                .mask(
                    Capsule()
                        .fill(LinearGradient(gradient: .init(colors: [.clear, AppStyle.theme.iconColor, .clear]), startPoint: .top, endPoint: .bottom))
                        .rotationEffect(.degrees(30))
                        .offset(x: showSkeletonAnimation ? -70 : 70)
                )
        }
    }
}

// MARK: - Error view

private extension VideoPlayerView {
    var errorView: some View {
        return Button {
            videoVM.loadURL(videoURL, forceLoad: true)
        } label: {
            VStack(spacing: AppStyle.layout.standardSpace) {
                errorIcon
                noCameraText
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(AppStyle.theme.iconOffColor)
        }
    }

    var errorIcon: some View {
        return Image(systemName: "exclamationmark.circle")
            .applyTheme(.white)
            .scaleEffect(2)
    }

    var noCameraText: some View {
        return Text("Video error")
            .font(AppStyle.font.medium18)
            .foregroundColor(.white)
    }
}
