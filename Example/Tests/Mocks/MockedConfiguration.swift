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
    var publicKeys: PublicKeys?
    var loggers: [Logger]?    
    var mockedHeaders: RequestHeaders?
    
    init(baseURL: URL?, headers: RequestHeaders? = nil, publicKeys: PublicKeys? = nil) {
        self.baseURL = baseURL
        self.mockedHeaders = headers
        self.publicKeys = publicKeys
    }
    
    func headers(for request: Request) -> RequestHeaders? {
        return mockedHeaders
    }
}
