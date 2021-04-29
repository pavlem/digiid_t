//
//  Enc.swift
//  DigiIdentity_test
//
//  Created by Pavle Mijatovic on 3.5.21..
//

import Foundation
import CommonCrypto

struct AES256 {
    
    private var key: Data
    private var iv: Data
    
    public init(key: Data, iv: Data) throws {
        guard key.count == kCCKeySizeAES256 else {
            throw Error.badKeyLength
        }
        guard iv.count == kCCBlockSizeAES128 else {
            throw Error.badInputVectorLength
        }
        self.key = key
        self.iv = iv
    }
    
    enum Error: Swift.Error {
        case keyGeneration(status: Int)
        case cryptoFailed(status: CCCryptorStatus)
        case badKeyLength
        case badInputVectorLength
    }

    func encrypt(_ digest: Data) throws -> Data {
        return try crypt(input: digest, operation: CCOperation(kCCEncrypt))
    }
    
    func decrypt(_ encrypted: Data) throws -> Data {
        return try crypt(input: encrypted, operation: CCOperation(kCCDecrypt))
    }
    
    private func crypt(input: Data, operation: CCOperation) throws -> Data {
        var outLength = Int(0)
        var outBytes = [UInt8](repeating: 0, count: input.count + kCCBlockSizeAES128)
        var status: CCCryptorStatus = CCCryptorStatus(kCCSuccess)
        input.withUnsafeBytes { (encryptedBytes: UnsafePointer<UInt8>!) -> () in
            iv.withUnsafeBytes { (ivBytes: UnsafePointer<UInt8>!) in
                key.withUnsafeBytes { (keyBytes: UnsafePointer<UInt8>!) -> () in
                    status = CCCrypt(operation,
                                     CCAlgorithm(kCCAlgorithmAES128),            // algorithm
                                     CCOptions(kCCOptionPKCS7Padding),           // options
                                     keyBytes,                                   // key
                                     key.count,                                  // keylength
                                     ivBytes,                                    // iv
                                     encryptedBytes,                             // dataIn
                                     input.count,                                // dataInLength
                                     &outBytes,                                  // dataOut
                                     outBytes.count,                             // dataOutAvailable
                                     &outLength)                                 // dataOutMoved
                }
            }
        }
        guard status == kCCSuccess else {
            throw Error.cryptoFailed(status: status)
        }
        return Data(bytes: UnsafePointer<UInt8>(outBytes), count: outLength)
    }
    
    static func createKey(password: Data, salt: Data) throws -> Data {
        let length = kCCKeySizeAES256
        var status = Int32(0)
        var derivedBytes = [UInt8](repeating: 0, count: length)
        password.withUnsafeBytes { (passwordBytes: UnsafePointer<Int8>!) in
            salt.withUnsafeBytes { (saltBytes: UnsafePointer<UInt8>!) in
                status = CCKeyDerivationPBKDF(CCPBKDFAlgorithm(kCCPBKDF2),                  // algorithm
                                              passwordBytes,                                // password
                                              password.count,                               // passwordLen
                                              saltBytes,                                    // salt
                                              salt.count,                                   // saltLen
                                              CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA1),   // prf
                                              10000,                                        // rounds
                                              &derivedBytes,                                // derivedKey
                                              length)                                       // derivedKeyLen
            }
        }
        guard status == 0 else {
            throw Error.keyGeneration(status: Int(status))
        }
        return Data(bytes: UnsafePointer<UInt8>(derivedBytes), count: length)
    }
}

extension Data {
    var hexString: String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}

func stringArrayToData(stringArray: [String]) -> Data? {
  return try? JSONSerialization.data(withJSONObject: stringArray, options: [])
}

func dataToStringArray(data: Data) -> [String]? {
  return (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String]
}
