//
//  VCLPlayerDefine.swift
//  VLC Example
//
//  Created by dtrognn on 05/06/2024.
//

import Foundation

public enum MediaPlayerState {
    case unAvailable
    case openning
    case playing
    case paused
    case ended
    case error
}

enum VLCPlayerConfig {
    static let aspectRatio = "16:9"
    static let networkCaching = 300
    static let rtspFrameBufferSize = 4096
    static let output = "ios"
    static let glConv = "glconv_cvpx"
    static let rtspCaching = 0
    static let tcpCaching = 300
    static let httpsCaching = 300
    static let realRtspCaching = 300
    static let liveRtspCaching = 0
    static let h264fps = 60.0
    static let mmsTimeout = 10000
}
