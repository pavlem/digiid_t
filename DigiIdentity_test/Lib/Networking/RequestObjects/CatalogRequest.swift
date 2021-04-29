//
//  CatalogRequest.swift
//  DigiIdentity_test
//
//  Created by Pavle Mijatovic on 1.5.21..
//

import Foundation

struct CatalogRequest: Encodable {
    let maxId: String?
    let sinceId: String?
}

extension CatalogRequest {
    func body() -> NetworkService.JSON {
        var params = [String: String]()
        
        if let maxId = self.maxId {
            params["max_id"] = maxId
        }
        
        if let sinceId = self.sinceId {
            params["since_id"] = sinceId
        }
        
        return params
    }
}
