//
//  NetworkReachabilitySpec.swift
//  Tests
//
//  Created by Dylan Gyesbreghs on 02/01/2019.
//  Copyright © 2019 icapps. All rights reserved.
//

import Quick
import Nimble
import Mockingjay

@testable import Cara

class NetworkReachabilitySpec: QuickSpec {
    
    class MockedNetworkReachability: NetworkReachability {
        private(set) var didTriggerStartListening: Bool = false
        private(set) var didTriggerStopListening: Bool = false
        override func startListening() {
            didTriggerStartListening = true
        }
        override func stopListening() {
            didTriggerStopListening = true
        }
    }
    
    override func spec() {
        describe("NetworkReachability") {
            var configuration: MockedConfiguration!
            var networkReachability: MockedNetworkReachability!
            beforeEach {
                configuration = MockedConfiguration(baseURL: URL(string: "https://relative.com/"))
                networkReachability = MockedNetworkReachability(configuration: configuration)
            }

            it("should trigger start listening") {
                networkReachability.startListening()
                expect(networkReachability.didTriggerStartListening) == true
            }
            
            it("should trigger stop listening") {
                networkReachability.stopListening()
                expect(networkReachability.didTriggerStopListening) == true
            }
        }
    }
}
