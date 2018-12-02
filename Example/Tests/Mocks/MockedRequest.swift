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
    
    init(url: URL?, method: RequestMethod = .get) {
        self.url = url
        self.method = method
    }
}
