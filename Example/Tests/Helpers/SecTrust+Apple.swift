//
//  SecTrust+Apple.swift
//  Tests
//
//  Created by Jelle Vandebeeck on 30/12/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import Security

private class MockedTrust {
}

extension SecTrust {
    static var apple: SecTrust {
        let certificateURL = Bundle(for: MockedTrust.self).url(forResource: "apple.com", withExtension: "cer")!
        // swiftlint:disable force_try
        let certificateData = try! Data(contentsOf: certificateURL)
        var certificate: SecCertificate?
        if certificateData.count > 0 {
            certificate = SecCertificateCreateWithData(nil, certificateData as CFData)
        }
        
        var optionalSecTrust: SecTrust?
        let policy = SecPolicyCreateBasicX509()
        let certificates = [certificate] as CFArray
        SecTrustCreateWithCertificates(certificates, policy, &optionalSecTrust)
        return optionalSecTrust!
    }
    // swiftlint:enable force_try
}
