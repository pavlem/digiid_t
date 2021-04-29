//
//  CatalogResponse.swift
//  DigiIdentity_test
//
//  Created by Pavle Mijatovic on 1.5.21..
//

import Foundation

struct CatalogResponse: Decodable {
    let text: String
    let confidence: Float
    let img: String
    let id: String
    
    enum CodingKeys: String, CodingKey {
        case text, confidence, img
        case id = "_id"
    }
}


