//
//  MockedRequest.swift
//  Tests
//
//  Created by Jelle Vandebeeck on 02/12/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Cara

class MockedRequest: Request {
    var url: URL?
    var method: RequestMethod
    var headers: RequestHeaders?
    
    init(url: URL?, method: RequestMethod = .get, headers: RequestHeaders? = nil) {
        self.url = url
        self.method = method
        self.headers = headers
    }
}
