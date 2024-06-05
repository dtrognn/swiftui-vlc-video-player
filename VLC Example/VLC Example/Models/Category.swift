//
//  Category.swift
//  VLC Example
//
//  Created by dtrognn on 05/06/2024.
//

import Foundation

struct Category: Codable {
    let name: String
    let videos: [Video]

    init() {
        self.name = ""
        self.videos = []
    }

    enum CodingKeys: String, CodingKey {
        case name
        case videos
    }
}

struct Video: Codable, Identifiable {
    let id: String = UUID().uuidString
    let description: String
    let sources: [String]
    let subtitle: Subtitle
    let thumb: String
    let title: String

    enum CodingKeys: String, CodingKey {
        case description
        case sources
        case subtitle
        case thumb
        case title
    }

    var thumbURL: String {
        return String(format: "%@%@", baseMediaURL, thumb)
    }
}

enum Subtitle: String, Codable {
    case byBlenderFoundation = "By Blender Foundation"
    case byGarage419 = "By Garage419"
    case byGoogle = "By Google"
}
