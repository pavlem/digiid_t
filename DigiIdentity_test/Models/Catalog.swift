//
//  Catalog.swift
//  DigiIdentity_test
//
//  Created by Pavle Mijatovic on 4.5.21..
//

import UIKit

struct Catalog: Codable {
    let name: String
    let confidence: String
    let id: String
    let imageBase64: String
    
    var image: UIImage {
        return Catalog.convertBase64ToImage(imageString: self.imageBase64)
    }
}

extension Catalog {
    init(catalogCellVM: CatalogCellVM) {
        self.name = catalogCellVM.name
        self.confidence = catalogCellVM.confidence
        self.id = catalogCellVM.id
        self.imageBase64 = Catalog.convertImageToBase64(image: catalogCellVM.image)
    }
    
    static func convertImageToBase64(image: UIImage) -> String {
        let imageData = image.pngData()!
        return imageData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
    }

    static func convertBase64ToImage(imageString: String) -> UIImage {
        let imageData = Data(base64Encoded: imageString, options: Data.Base64DecodingOptions.ignoreUnknownCharacters)!
        return UIImage(data: imageData) ?? UIImage()
    }
}
