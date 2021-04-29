//
//  UserDefaultsHelper.swift
//  DigiIdentity_test
//
//  Created by Pavle Mijatovic on 3.5.21..
//

import Foundation

class UserDefaultsHelper {
    
    static let shared = UserDefaultsHelper()
    
    enum Keys: String, CaseIterable {
        case catalogs
        
        var string: String {
            return self.rawValue
        }
    }
    
    // MARK: - Properties
    var catalogs: Data? {
        get {
            return UserDefaults.standard.data(forKey: Keys.catalogs.string)
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.catalogs.string)
            UserDefaults.standard.synchronize()
        }
    }
}
