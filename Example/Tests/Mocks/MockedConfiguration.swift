//
//  MockedConfiguration.swift
//  Tests
//
//  Created by Jelle Vandebeeck on 02/12/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Cara

class MockedConfiguration: Cara.Configuration {
    var baseURL: URL?
    var headers: RequestHeaders?
    var publicKeys: PublicKeys?
    
    init(baseURL: URL?, headers: RequestHeaders? = nil, publicKeys: PublicKeys? = nil) {
        self.baseURL = baseURL
        self.headers = headers
        self.publicKeys = publicKeys
    }
}
