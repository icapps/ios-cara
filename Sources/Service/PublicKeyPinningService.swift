//
//  PublicKeyPinningService.swift
//  Cara
//
//  Created by Jelle Vandebeeck on 30/12/2018.
//

import Foundation
import Security
import CommonCrypto

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
    
    func handle(_ serverTrust: SecTrust,
                host: String,
                completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard
            let publicKeys = configuration.publicKeys,
            let publicKeyString = publicKeys[host] else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        
        let certificateChainLen = SecTrustGetCertificateCount(serverTrust)
        for index in (0..<certificateChainLen).reversed() {
            // When the certificate can not be obtained, continue to the next certificate.
            guard let certificate = SecTrustGetCertificateAtIndex(serverTrust, index) else { continue }
            
            // Generate the public key for the secure server trust.
            var optionalSecTrust: SecTrust?
            let policy = SecPolicyCreateBasicX509()
            let certificates = [certificate] as CFArray
            SecTrustCreateWithCertificates(certificates, policy, &optionalSecTrust)
            // When the public key can not be obtained, continue to the next certificate.
            guard
                let secTrust = optionalSecTrust,
                let publicKey = SecTrustCopyPublicKey(secTrust) else { continue }

            var error: Unmanaged<CFError>?
            if let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, &error) {
                var keyWithHeader = Data(rsa2048Asn1Header)
                keyWithHeader.append(publicKeyData as Data)
                let sha256 = keyWithHeader.sha256
                // When the public keys don't match continue to the next certificate.
                guard sha256.base64EncodedString() == publicKeyString else { continue }                
                completionHandler(.useCredential, URLCredential(trust: secTrust))
                return
            }
        }
        
        completionHandler(.cancelAuthenticationChallenge, nil)
    }
}

private extension Data {
    var sha256: Data {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        withUnsafeBytes { _ = CC_SHA256($0.baseAddress, CC_LONG(self.count), &hash) }
        return Data(hash)

    }
}
