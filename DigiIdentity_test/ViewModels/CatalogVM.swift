//
//  CatalogVM.swift
//  DigiIdentity_test
//
//  Created by Pavle Mijatovic on 3.5.21..
//

import Foundation

extension CatalogVM {
    convenience init(isLoadingScreenShown: Bool) {
        self.init()
        
        self.isLoadingScreenShown = isLoadingScreenShown
    }
}

class CatalogVM {
    
    // MARK: - API
    var isLoadingScreenShown = true
    
    let noMoreCatalogsMessage = "No more catalogs, please try again later"
    let noNewCatalogsMessage = "No new catalogs, please try again later"
    let catalogList = "Catalog List"
    let numberOfLoadedPersitedCatalogs = 10 

    func cancelCatalogsFetch() {
        dataTask?.cancel()
    }
    
    func persist(catalogs: [CatalogCellVM]) {
        UserDefaultsHelper.shared.catalogs = try? CatalogVM.cryptorHelper.encode(catalogCellVMs: catalogs)
    }
    
    func fetchCatalogs(maxId: String? = nil, sinceId: String? = nil, completion: @escaping (Result<[CatalogCellVM], NetworkError>) -> ()) {
        
        fetchData(maxId: maxId, sinceId: sinceId) { result in completion(result) }
    }
    
    func loadPersistedCatalogs(forFirst n: Int, success: ([CatalogCellVM]) -> Void) {
        if let catalogVMs = try? CatalogVM.cryptorHelper.decode(encryptedCatalogs: UserDefaultsHelper.shared.catalogs) {
            success(Array(catalogVMs[0..<n]))
        }
    }
    
    // MARK: - Properties
    private static var cryptorHelper = CryptorHelper(password: "paja", saltString: "x4vV8bGgqqmQwgCoyXFQj+(o.nUNQhVP7ND", ivString: "abcdefghijklmnop")

    private var dataTask: URLSessionDataTask?
    private let catalogService = CatalogService()
    
    // MARK: - Helper
    private func fetchData(maxId: String? = nil, sinceId: String? = nil, completion: @escaping (Result<[CatalogCellVM], NetworkError>) -> ()) {
        
        let catalogReq = CatalogRequest(maxId: maxId, sinceId: sinceId)
        
        dataTask = catalogService.fetchCatalogs(catalogRequest: catalogReq) { (result) in
            
            switch result {
            
            case .failure(let err):
                completion(.failure(NetworkError.error(err: err)))
            
            case .success(let catalogsResponse):
                guard let catalogsResponse = catalogsResponse else { return }
                let catalogs = catalogsResponse.map { CatalogCellVM(catalogResponse: $0) }

                guard sinceId == nil else {
                    var reversedCatalogs = [CatalogCellVM]()
                    for arrayIndex in stride(from: catalogsResponse.count - 1, through: 0, by: -1) {
                        reversedCatalogs.append(catalogs[arrayIndex])
                    }
                    completion(.success(reversedCatalogs))
                    return
                }
                
                completion(.success(catalogs))
            }
        }
    }
}
