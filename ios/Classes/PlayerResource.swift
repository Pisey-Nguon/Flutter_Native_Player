//
//  PlayerResource.swift
//  flutter_native_player
//
//  Created by Nguon Pisey on 19/1/22.
//

import Foundation
// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let playerResource = try? newJSONDecoder().decode(PlayerResource.self, from: jsonData)

// MARK: - PlayerResource
struct PlayerResource: Codable {
    let videoUrl: String
    let playerSubtitleResources: [PlayerSubtitleResource]


}

// MARK: - Subtitle
struct PlayerSubtitleResource: Codable {
    let subtitleUrl, language: String
}
