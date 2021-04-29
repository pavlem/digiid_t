//
//  CatalogDetailVM.swift
//  DigiIdentity_test
//
//  Created by Pavle Mijatovic on 5.5.21..
//

import UIKit

struct CatalogDetailVM {
    let name: String
    let confidence: String
    let id: String
    let image: UIImage
    
    let backgroundColor = UIColor(red: 66/255.0, green: 66/255.0, blue: 66/255.0, alpha: 1)

    let confidenceLblFont = UIFont.boldSystemFont(ofSize: 16)
    let idLblFont = UIFont.systemFont(ofSize: 16)
    let deleteBtnFont = UIFont.boldSystemFont(ofSize: 20)
    
    let confidenceLblColor = UIColor.white
    let idLblColor = UIColor.white
    let btnTextColor = UIColor.black
    
    var isLoadingScreenShown = false

    let deleteBtnTitle = "Delete catalog"
    
    var descriptionOfID: String {
        return "ID: " + id
    }
    
    func cancelCatalogsFetch() {
        dataTask?.cancel()
    }
    
    mutating func deleteCatalog(id: String, completion: @escaping (Result<DeleteCatalogResponse?, NetworkError>) -> ()) {
        
        dataTask = catalogService.deleteCatalog(id: id) { result in
            completion(result)
        }
    }
    
    // MARK: - Properties
    private var dataTask: URLSessionDataTask?
    private let catalogService = CatalogService()
}
 
extension CatalogDetailVM {
    init(catalogCellVM: CatalogCellVM) {
        name = catalogCellVM.name.uppercased()
        confidence = catalogCellVM.confidence
        id = catalogCellVM.id
        image = catalogCellVM.image
    }
}
