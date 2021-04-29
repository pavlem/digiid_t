//
//  CryptorHelper.swift
//  DigiIdentity_test
//
//  Created by Pavle Mijatovic on 4.5.21..
//

import Foundation

class CryptorHelper {
    
    // MARK: - API
    func encode(catalogCellVMs: [CatalogCellVM]?) throws -> Data? {
        do {
            guard let catalogCellVMs = catalogCellVMs else { return nil }
            let catalogs = catalogCellVMs.map {Catalog(catalogCellVM: $0)}
            let dataOfObjects = try encoder.encode(catalogs)
            let key = try AES256.createKey(password: password.data(using: .utf8)!, salt: salt)
            let aes = try AES256(key: key, iv: iv)
            let encryptedCatalogs = try aes.encrypt(dataOfObjects)
            return encryptedCatalogs
        } catch {
            return nil
        }
    }
    
    func decode(encryptedCatalogs: Data?) throws -> [CatalogCellVM]? {
        do {
            guard let encryptedCatalogs = encryptedCatalogs else { return nil }
            let key = try AES256.createKey(password: password.data(using: .utf8)!, salt: salt)
            let aes = try AES256(key: key, iv: iv)
            let decryptedCatalogs = try aes.decrypt(encryptedCatalogs)
            let decryptedCatalogsDecoded = try decoder.decode([Catalog].self, from: decryptedCatalogs)
            let catalogVMs = decryptedCatalogsDecoded.map { CatalogCellVM(catalog: $0) }
            return catalogVMs
        } catch {
            return nil
        }
    }
    
    // MARK: - Properties
    private let password: String
    private let saltString: String
    private let ivString: String
    
    private var iv: Data {
        return ivString.data(using: .utf8)!
    }
    
    private var salt: Data {
        return saltString.data(using: .utf8)!
    }
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    // MARK: - Inits
    init(password: String, saltString: String, ivString: String) {
        self.password = password
        self.saltString = saltString
        self.ivString = ivString
    }
}
