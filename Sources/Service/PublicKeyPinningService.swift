//
//  PublicKeyPinningService.swift
//  Cara
//
//  Created by Jelle Vandebeeck on 30/12/2018.
//

import Foundation
import CryptoSwift

class PublicKeyPinningService {
    
    // MARK: - Internal
    
    private let configuration: Configuration
    private let rsa2048Asn1Header: [UInt8] = [
        0x30, 0x82, 0x01, 0x22, 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
        0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x01, 0x0f, 0x00
    ]
    
    // MARK: - Init
    
    init(configuration: Configuration) {
        self.configuration = configuration
    }
    
    // MARK: - Handler
    
    func handle(challenge: URLAuthenticationChallenge,
                completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let host = challenge.protectionSpace.host
        guard
            let serverTrust = challenge.protectionSpace.serverTrust,
            challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust else {
            print("🔑 Public key pinning failed due to invalid trust for host", host)
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        guard
            let publicKeys = configuration.publicKeys,
            let publicKeyString = publicKeys[host] else {
                print("🔑 Public key pinning not available for host", host)
                completionHandler(.performDefaultHandling, nil)
                return
        }
        
        SecTrustSetPolicies(serverTrust, SecPolicyCreateSSL(true, host as CFString))
        guard serverTrust.isValid else { return }
        
        let certificateChainLen = SecTrustGetCertificateCount(serverTrust)
        for index in (0..<certificateChainLen).reversed() {
            guard let certificate = SecTrustGetCertificateAtIndex(serverTrust, index) else {
                print("🔑 Public key pinning failed due to invalid certificate for", index, host)
                //                completionHandler(.cancelAuthenticationChallenge, nil)
                continue
            }
            
            // Generate the public key for the secure server trust.
            var optionalSecTrust: SecTrust?
            let policy = SecPolicyCreateBasicX509()
            let certificates = [certificate] as CFArray
            SecTrustCreateWithCertificates(certificates, policy, &optionalSecTrust)
            guard
                let secTrust = optionalSecTrust,
                let publicKey = SecTrustCopyPublicKey(secTrust) else {
                    print("🔑 Public key pinning failed due to invalid remote public key for", index, host)
                    //                    completionHandler(.cancelAuthenticationChallenge, nil)
                    continue
            }
            
            var error: Unmanaged<CFError>?
            if let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, &error) {
                var keyWithHeader = Data(bytes: rsa2048Asn1Header)
                keyWithHeader.append(publicKeyData as Data)
                let sha256 = keyWithHeader.sha256()
                print(sha256.base64EncodedString())
                if sha256.base64EncodedString() == publicKeyString {
                    print("🔑 Handle public key pinning for host", index, host)
                    completionHandler(.useCredential, URLCredential(trust: secTrust))
                    return
                } else {
                    print("🔑 Public key pinning failed due to invalid match for ", index, host)
                    //                    completionHandler(.cancelAuthenticationChallenge, nil)
                    continue
                }
            }
        }
        
        print("🔑 Public key pinning failed due to invalid representation for ", host)
        completionHandler(.cancelAuthenticationChallenge, nil)
    }
}

extension SecTrust {
    var isValid: Bool {
        var result = SecTrustResultType.invalid
        let status = SecTrustEvaluate(self, &result)
        if status == errSecSuccess {
            return result == SecTrustResultType.unspecified || result == SecTrustResultType.proceed
        }
        return false
    }
}
