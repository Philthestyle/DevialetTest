//
//  ProductType.swift
//  DevialetTest
//
//  Created by Faustin on 15/09/2023.
//

import Foundation

// MARK: - ProductJoined

struct ProductJoined: Decodable {
    let serial: String
    let type: String
}

// MARK: - ProductLeft

struct ProductLeft: Decodable {
    let serial: String
}

// MARK: - Enum 'ProductType' with associated values
/*
 To Decode different types of data from WS /home/{serial} endpoint to use data on 'ProductListViewController'
 so we are able to decode data from 'ProductJoined' or 'ProductLeft' structs depending on message received from WS
 */
enum ProductType: Decodable {
    case productJoined(ProductJoined)
    case productLeft(ProductLeft)

    // Define associated values as keys
    enum CodingKeys: String, CodingKey {
        case productJoined
        case productLeft
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Try to decode container as 'ProductJoined' struct
        if let product = try container.decodeIfPresent(ProductJoined.self, forKey: .productJoined) {
            self = .productJoined(product)
            return
        }

        // Try to decode container as 'ProductLeft' struct
        if let productLeft = try container.decodeIfPresent(ProductLeft.self, forKey: .productLeft) {
            self = .productLeft(productLeft)
            return
        }

        // throw error
        throw DecodingError.dataCorruptedError(forKey: .productJoined, in: container, debugDescription: "No match for '.productJoined'")
    }
}

extension ProductJoined {
    enum SpeakerType: CaseIterable {
      case mania
      case phantom
      
      var description: String {
        switch self {
        case .mania:
            return "Mania"
        case .phantom:
            return "Phantom II"
        }
      }
    }

    // MARK: - Testing and Debugging purpose
    
    static var MOCK_ProductJoined: [ProductJoined] = [
        .init(serial: UUID().uuidString.uppercased(), type: SpeakerType.allCases.randomElement()!.description),
        .init(serial: UUID().uuidString.uppercased(), type: SpeakerType.allCases.randomElement()!.description),
        .init(serial: UUID().uuidString.uppercased(), type: SpeakerType.allCases.randomElement()!.description),
        .init(serial: UUID().uuidString.uppercased(), type: SpeakerType.allCases.randomElement()!.description),
        .init(serial: UUID().uuidString.uppercased(), type: SpeakerType.allCases.randomElement()!.description),
        .init(serial: UUID().uuidString.uppercased(), type: SpeakerType.allCases.randomElement()!.description),
        .init(serial: UUID().uuidString.uppercased(), type: SpeakerType.allCases.randomElement()!.description)
    ]
}
