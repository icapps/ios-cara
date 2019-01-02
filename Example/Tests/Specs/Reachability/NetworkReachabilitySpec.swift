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
import Connectivity

@testable import Cara

class NetworkReachabilitySpec: QuickSpec {
    
    class MockedNetworkReachability: NetworkReachability {        
        override func startListening() {
            guard let listener = listener else { return }
            listener(ConnectivityStatus.connectedViaWiFi)
        }
    }
    
    override func spec() {
        describe("CodableSerializer") {
            var networkReachability: NetworkReachability!
            beforeEach {
                networkReachability = MockedNetworkReachability()
            }
            
            it("should return ConnectivityStatus.connectedViaWiFi.") {
                waitUntil { done in
                    networkReachability.listener = { status in
                        expect(status) == ConnectivityStatus.connectedViaWiFi
                        done()
                    }
                    networkReachability.startListening()
                }
            }
        }
    }
}
