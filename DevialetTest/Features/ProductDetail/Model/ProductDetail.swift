//
//  ProductDetail.swift
//  DevialetTest
//
//  Created by Faustin on 15/09/2023.
//


import Foundation

// MARK: - Music

struct Music: Decodable {
    let title: String
    let cover: String
    let artist: String
}


// MARK: - Battery

struct Battery: Decodable {
    let percent: Int
}


// MARK: - Enum 'ProductDetail' with associated values
/*
 To Decode different types of data from WS /home/{serial} endpoint to use data on 'ProductDetailViewController' - so we are able to decode data from 'Music' or 'Battery' structs depending on message received from WS
 */
enum ProductDetail: Decodable {
    case playing(Music)
    case battery(Battery)

    // Define associated values as keys
    enum CodingKeys: String, CodingKey {
        case playing
        case battery
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Try to decode as 'Music'
        if let music = try container.decodeIfPresent(Music.self, forKey: .playing) {
            self = .playing(music)
            return
        }

        // Try to decode as 'Battery'
        if let battery = try container.decodeIfPresent(Battery.self, forKey: .battery) {
            self = .battery(battery)
            return
        }

        // throw error
        throw DecodingError.dataCorruptedError(forKey: .playing, in: container, debugDescription: "no match for '.playing'")
    }
}
