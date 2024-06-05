//
//  CommonVideoPlayerView.swift
//  VLC Example
//
//  Created by dtrognn on 05/06/2024.
//

import Combine
import MobileVLCKit
import SwiftUI

public struct CommonVideoPlayerView: UIViewRepresentable {
    @ObservedObject var vm: CommonVideoPlayerViewModel

    public init(vm: CommonVideoPlayerViewModel) {
        self.vm = vm
    }

    public func makeUIView(context: Context) -> some UIView {
        let uiView = vm.uiView
        return uiView
    }

    public func updateUIView(_ uiView: UIViewType, context: Context) {}
}

public class CommonVideoPlayerViewModel: NSObject, ObservableObject {
    var uiView = UIView()

    public enum ThumbnailState {
        case detectSuccess(UIImage?)
        case invalid
    }

    public var onError = PassthroughSubject<Void, Never>()
    public var onConnectNetwork = PassthroughSubject<Bool, Never>()
    public var onVideoStartPlaying = PassthroughSubject<Void, Never>()
    public var onUpdateFrame = PassthroughSubject<Bool, Never>()
    public var onUpdateThumbnailState = PassthroughSubject<ThumbnailState, Never>()

    private lazy var mediaPlayer: VLCMediaPlayer = {
        var player = VLCMediaPlayer()
//        var player = VLCMediaPlayer(options: ["--extraintf="])
        return player
    }()

    private var thumbnailer: VLCMediaThumbnailer?
    private var isMediaPlayerTimeChanged: Bool = false
    private var timerOpening: Timer.TimerPublisher?
    private var counterOpening: Int = 0
    private var cancellableSet: Set<AnyCancellable> = []
    private var prevousURL: String?
    private var isFirstLoad: Bool = true

    private let openingTimeout: Int = 30

    @Published public var isPlaying: Bool = false
    @Published public var isMute: Bool = false
    @Published public var mediaPlayerState: MediaPlayerState = .unAvailable

    override public init() {
        super.init()
        mediaPlayer.delegate = self
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        thumbnailer?.delegate = nil
        thumbnailer = nil
    }

    public func loadPreviousUrl() {
        loadURL(prevousURL ?? "", forceLoad: true)
    }

    public func loadURL(_ urlString: String, forceLoad: Bool = false, isPlayImmediately: Bool = true, thumbnailWidth: CGFloat? = nil, thumbnailHeight: CGFloat? = nil) {
        if forceLoad {
            configMediaPlayer(urlString, isPlayImmediately: isPlayImmediately, thumbnailWidth: thumbnailWidth, thumbnailHeight: thumbnailHeight)
        } else {
            if urlString == prevousURL { return }
            configMediaPlayer(urlString, isPlayImmediately: isPlayImmediately, thumbnailWidth: thumbnailWidth, thumbnailHeight: thumbnailHeight)
        }
    }

    public func updateFrame(_ show: Bool) {
        onUpdateFrame.send(show)
    }

    public func pause() {
        mediaPlayer.pause()
        isPlaying = false
    }

    public func play() {
        mediaPlayer.play()
        isPlaying = true
    }

    public func stop() {
        mediaPlayer.stop()
        isPlaying = false
    }

    public func forward() {
        guard let currentTime = mediaPlayer.time.value as? Int32 else { return }
        let newValue = currentTime + 10
        mediaPlayer.time = VLCTime(int: newValue)
    }

    public func backward() {
        guard let currentTime = mediaPlayer.time.value as? Int32 else { return }
        let newValue = currentTime - 10
        mediaPlayer.time = VLCTime(int: newValue)
    }

    public func mute() {
        mediaPlayer.audio?.isMuted = true
        isMute = true
    }

    public func unmute() {
        mediaPlayer.audio?.isMuted = false
        isMute = false
    }

    public func maxTime() -> Int32 {
        guard let media = mediaPlayer.media?.length.intValue else { return 0 }
        return media
    }

    public func currentTime() -> Int32 {
        guard let currentTime = mediaPlayer.time.value as? Int32 else { return 0 }
        return currentTime
    }

    public func setAudio(_ audio: Int) {
        mediaPlayer.audio?.volume = Int32(audio)
    }

    private func configMediaPlayer(_ urlString: String, isPlayImmediately: Bool = true, thumbnailWidth: CGFloat? = nil, thumbnailHeight: CGFloat? = nil) {
        guard !urlString.isEmpty, let url = URL(string: urlString) else {
            mediaPlayerState = .error
            return
        }

        prevousURL = urlString
        isFirstLoad = true

//        mediaPlayer.delegate = self
        mediaPlayer.videoAspectRatio = UnsafeMutablePointer<Int8>(mutating: (VLCPlayerConfig.aspectRatio as NSString).utf8String)
        mediaPlayer.drawable = uiView
        uiView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let media = VLCMedia(url: url)
        configThumbnail(media, width: thumbnailWidth, height: thumbnailHeight)
        media.addOptions([
            "network-caching": VLCPlayerConfig.networkCaching,
//            "--rtsp-frame-buffer-size": VLCPlayerConfig.rtspFrameBufferSize,
            "--codec": "avcodec",
            "--avcodec-hw": "none",
//            "--glconv": VLCPlayerConfig.glConv,
//            "--rtsp-caching=": VLCPlayerConfig.rtspCaching,
//            "--tcp-caching=": VLCPlayerConfig.tcpCaching,
//            "--https-caching=": VLCPlayerConfig.httpsCaching,
//            "--realrtsp-caching=": VLCPlayerConfig.realRtspCaching,
//            "--h264-fps": VLCPlayerConfig.h264fps,
//            "--h264-fps": VLCPlayerConfig.h264fps,
            "--file-caching": 2000,
            "--mms-timeout": VLCPlayerConfig.mmsTimeout,
            "--rtsp-tcp": true,
//            "--live-caching": VLCPlayerConfig.liveRtspCaching
        ])
//        media.addOption(":clock-jitter=0");
//        media.addOption(":clock-synchro=0");

//        #if DEBUG
//            mediaPlayer.libraryInstance.debugLogging = true
//            mediaPlayer.libraryInstance.debugLoggingLevel = 3
//        #endif

        mediaPlayer.media = media
        if isPlayImmediately {
            play()
        }
    }

    private func configThumbnail(_ media: VLCMedia, width: CGFloat? = nil, height: CGFloat? = nil) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.thumbnailer = VLCMediaThumbnailer(media: media, andDelegate: self)
            self.thumbnailer?.delegate = self
            self.thumbnailer?.snapshotPosition = 0.0
            if let width = width {
                self.thumbnailer?.thumbnailWidth = width
            }
            if let height = height {
                self.thumbnailer?.thumbnailHeight = height
            }
            self.thumbnailer?.fetchThumbnail()
        }
    }

    private func startTimerOpening() {
        stopTimerOpening()
        timerOpening = Timer.publish(every: 3, on: .main, in: .default)
        timerOpening?.autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if counterOpening >= openingTimeout {
                    self.stopTimerOpening()
                    self.stop()
                    self.mediaPlayerState = .error
                }
                counterOpening += 3
            }.store(in: &cancellableSet)
    }

    private func stopTimerOpening() {
        counterOpening = 0
        timerOpening?.autoconnect().upstream.connect().cancel()
    }
}

// MARK: - VLCMediaPlayerDelegate

extension CommonVideoPlayerViewModel: VLCMediaPlayerDelegate {
    public func mediaPlayerStateChanged(_ aNotification: Notification) {
        guard let mediaPlayer = aNotification.object as? VLCMediaPlayer else { return }
        switch mediaPlayer.state {
        case .opening:
//            print("AAA mediaPlayerStateChanged opening")
            mediaPlayerState = .openning
            startTimerOpening()
        case .playing:
//            print("AAA mediaPlayerStateChanged playing")
            mediaPlayerState = .playing
            isPlaying = true
        case .paused:
//            print("AAA mediaPlayerStateChanged paused")
            mediaPlayerState = .paused
            isPlaying = false
        case .ended:
//            print("AAA mediaPlayerStateChanged ended")
            mediaPlayerState = .ended
            stopTimerOpening()
//            mediaPlayerState = .error
            isPlaying = false
        case .error:
            print("AAA mediaPlayerStateChanged \(mediaPlayer.debugDescription)")
            mediaPlayerState = .error
            stopTimerOpening()
            isPlaying = false
        default:
            break
        }
    }

    public func mediaPlayerTimeChanged(_ aNotification: Notification) {
        if isFirstLoad {
            onVideoStartPlaying.send(())
            stopTimerOpening()
            isFirstLoad = false
//            print("AAA mediaPlayerTimeChanged")
        }
    }

    public func mediaPlayerSnapshot(_ aNotification: Notification) {
        print("AAA mediaPlayerSnapshot")
    }

    public func mediaPlayerChapterChanged(_ aNotification: Notification) {
        print("AAA mediaPlayerChapterChanged")
    }

    public func mediaPlayerTitleChanged(_ aNotification: Notification) {
        print("AAA mediaPlayerTitleChanged")
    }

    public func mediaPlayerStartedRecording(_ player: VLCMediaPlayer) {
        print("AAA mediaPlayerStartedRecording")
    }
}

extension CommonVideoPlayerViewModel: VLCMediaThumbnailerDelegate {
    public func mediaThumbnailerDidTimeOut(_ mediaThumbnailer: VLCMediaThumbnailer) {
        print("AAA mediaThumbnailerDidTimeOut \(mediaThumbnailer)")
        onUpdateThumbnailState.send(.invalid)
    }

    public func mediaThumbnailer(_ mediaThumbnailer: VLCMediaThumbnailer, didFinishThumbnail thumbnail: CGImage) {
//        print("AAA mediaThumbnailer width: \(mediaThumbnailer.thumbnailWidth) - height: \(mediaThumbnailer.thumbnailHeight)")
        let thumbnail = UIImage(cgImage: thumbnail)
        onUpdateThumbnailState.send(.detectSuccess(thumbnail))
    }
}
