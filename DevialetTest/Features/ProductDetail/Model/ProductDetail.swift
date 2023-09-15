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

extension ProductDetail {
    
    // MARK: - Testing and Debugging purpose
    
    static var musicsMocks: [Music] = [
        Music(title: "Get Lucky", cover: "https://upload.wikimedia.org/wikipedia/en/7/71/Get_Lucky.jpg", artist: "Daft Punk"),
        Music(title: "Smile", cover: "https://i.scdn.co/image/ab67616d0000b273db63ed94970f5ad05de772bd", artist: "Télépopmusik"),
        Music(title: "Uprising", cover: "https://static.independent.co.uk/s3fs-public/thumbnails/image/2009/09/10/18/240854.jpg?quality=75&width=1200&auto=webp", artist: "Muse"),
        Music(title: "Caprice", cover: "https://cdns-images.dzcdn.net/images/cover/8ceb050b84fd7c1617ca0e95cea10537/500x500.jpg", artist: "Worakls")
    ]
    
    static var MOCK_Music: Music = musicsMocks.randomElement()!
    static var MOCK_Battery: Battery = .init(percent: Int.random(in: 1...100))
}
