//
//  CatalogVM.swift
//  DigiIdentity_test
//
//  Created by Pavle Mijatovic on 1.5.21..
//

import UIKit

struct CatalogCellVM {
    let name: String
    let confidence: String
    let id: String
    let image: UIImage
    
    let backgroundColor = UIColor(red: 66/255.0, green: 66/255.0, blue: 66/255.0, alpha: 1)
    let nameLblFont = UIFont.boldSystemFont(ofSize: 18)
    let confidenceLblFont = UIFont.boldSystemFont(ofSize: 16)
    let idLblFont = UIFont.systemFont(ofSize: 16)
    
    let nameLblColor = UIColor.white
    let confidenceLblColor = UIColor.white
    let idLblColor = UIColor.white
    
    let cellHeight = CGFloat(150)
    
    var detailedName: String {
        return "Name: " + name
    }
}

extension CatalogCellVM {
    init(catalogResponse: CatalogResponse) {
        name = catalogResponse.text
        confidence = "Confidence: " + String(catalogResponse.confidence)
        id = catalogResponse.id
        
        let dataDecoded = Data(base64Encoded: catalogResponse.img, options: .ignoreUnknownCharacters)!
        let decodedimage = UIImage(data: dataDecoded)
        image = decodedimage ?? UIImage()
    }
}

extension CatalogCellVM {
    init(catalog: Catalog) {
        name = catalog.name
        confidence = catalog.confidence
        id = catalog.id
        image = catalog.image
    }
}

