//
//  PublicKeyPinningServiceSpec.swift
//  Tests
//
//  Created by Jelle Vandebeeck on 30/12/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Quick
import Nimble

@testable import Cara

class PublicKeyPinningServiceSpec: QuickSpec {
    override func spec() {
        describe("PublicKeyPinningService") {
            var configuration: MockedConfiguration!
            var service: PublicKeyPinningService!
            
            it("should not handle the pinning when no public keys are available") {
                configuration = MockedConfiguration(baseURL: nil, publicKeys: nil)
                service = PublicKeyPinningService(configuration: configuration)
                
                waitUntil { done in
                    service.handle(SecTrust.apple, host: "apple.com") { (disposition, credential) in
                        expect(disposition) == .performDefaultHandling
                        expect(credential).to(beNil())
                        done()
                    }
                }
            }
            
            it("should not handle the pinning when no public keys for the given host is available") {
                configuration = MockedConfiguration(baseURL: nil, publicKeys: ["test.com": "123"])
                service = PublicKeyPinningService(configuration: configuration)
                
                waitUntil { done in
                    service.handle(SecTrust.apple, host: "apple.com") { (disposition, credential) in
                        expect(disposition) == .performDefaultHandling
                        expect(credential).to(beNil())
                        done()
                    }
                }
            }
                
            it("should correctly handle the pinning") {
                let keys = ["apple.com": "DNNeMh+L8ZhjxVL77wWSwAHMev8Bp+3/7Td1UZaJCXw="]
                configuration = MockedConfiguration(baseURL: nil, publicKeys: keys)
                service = PublicKeyPinningService(configuration: configuration)
                
                waitUntil { done in
                    service.handle(SecTrust.apple, host: "apple.com") { (disposition, credential) in
                        expect(disposition) == .useCredential
                        expect(credential).toNot(beNil())
                        done()
                    }
                }
            }
            
            it("should fail to handle the pinning for the incorrect pin") {
                let keys = ["apple.com": "DNNeMh+L8ZhjxVL77wWSwAHMev8Bp"]
                configuration = MockedConfiguration(baseURL: nil, publicKeys: keys)
                service = PublicKeyPinningService(configuration: configuration)
                
                waitUntil { done in
                    service.handle(SecTrust.apple, host: "apple.com") { (disposition, credential) in
                        expect(disposition) == .cancelAuthenticationChallenge
                        expect(credential).to(beNil())
                        done()
                    }
                }
            }
        }
    }
}
