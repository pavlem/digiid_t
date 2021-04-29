//
//  URLSessionPinningDelegate.swift
//  DigiIdentity_test
//
//  Created by Pavle Mijatovic on 5.5.21..
//

import Foundation

class URLSessionPinningDelegate: NSObject, URLSessionDelegate {
    
    // MARK: - API
    var isSSLPinningInOrder = true

    // MARK: - Properties
    private let certificateName = "marlove.net"
    private let certificateType = "cer"
    
    // MARK: - URLSessionPinningDelegate
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        
        if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
            if let serverTrust = challenge.protectionSpace.serverTrust {
                let isServerTrusted = SecTrustEvaluateWithError(serverTrust, nil)
                
                if(isServerTrusted) {
                    if let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) {
                        let serverCertificateData = SecCertificateCopyData(serverCertificate)
                        let data = CFDataGetBytePtr(serverCertificateData);
                        let size = CFDataGetLength(serverCertificateData);
                        let cert1 = NSData(bytes: data, length: size)
                        let fileCer = Bundle.main.path(forResource: certificateName, ofType: certificateType)
                        
                        if let file = fileCer {
                            if let cert2 = NSData(contentsOfFile: file) {
                                if cert1.isEqual(to: cert2 as Data) {
                                    completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust:serverTrust))
                                    return
                                }
                            }
                        }
                    }
                }
            }
        }
        
        self.isSSLPinningInOrder = false
        completionHandler(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
    }
}
