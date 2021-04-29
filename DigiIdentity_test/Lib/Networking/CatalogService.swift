//
//  CatalogService.swift
//  DigiIdentity_test
//
//  Created by Pavle Mijatovic on 29.4.21..
//

import UIKit

class CatalogService: NetworkService {
    
    // MARK: - API    
    func fetchCatalogs(catalogRequest: CatalogRequest?, completion: @escaping (Result<[CatalogResponse]?, NetworkError>) -> ()) -> URLSessionDataTask? {
        
        return load(urlString: urlString, path: self.path, method: .get, params: catalogRequest?.body() ?? nil, headers: authenticationHeader) { (result: Result<[CatalogResponse]?, NetworkError>) in
            
            switch result {
            case .success(let catalogResponse):
                completion(.success(catalogResponse))
            case .failure(let err):
                completion(.failure(err))
            }
        }
    }
    
    func deleteCatalog(id: String, completion: @escaping (Result<DeleteCatalogResponse?, NetworkError>) -> ()) -> URLSessionDataTask? {
        
        let deleteItemPath = self.deleteItemPath + id
        
        return load(urlString: urlString, path: deleteItemPath, method: .delete, params: nil, headers: authenticationHeader) { (result: Result<DeleteCatalogResponse?, NetworkError>) in
            
            switch result {
            case .success(let deleteResponse):
                completion(.success(deleteResponse))
            case .failure(let err):
                completion(.failure(err))
            }
        }
    }
    
    private var authenticationHeader: HTTPHeaders = ["Authorization": authenticationToken]
    static let authenticationToken = "b1432047825aaed5c28f1047ad146b30"
    
    // MARK: - Properties
    //    https://marlove.net/e/mock/v1/items
    private let scheme = "https://"
    private let host = "marlove.net/"
    private let path = "e/mock/v1/items"
    private let deleteItemPath = "e/mock/v1/item/"

    private var urlString: String {
        return scheme + host
    }
}
