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
    
    init(baseURL: URL?, headers: RequestHeaders? = nil) {
        self.baseURL = baseURL
        self.headers = headers
    }
}
