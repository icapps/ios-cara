//
//  MockedSerializer.swift
//  Tests
//
//  Created by Jelle Vandebeeck on 02/12/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Cara

struct MockedSerializer: Serializer {
    
    // MARK: - Response
    
    struct Response {
        var data: Data?
        var error: Error?
        var statusCode: Int?
    }
    
    // MARK: - Serializer
    
    func serialize(data: Data?, error: Error?, response: URLResponse?) -> MockedSerializer.Response {
        let urlResponse = response as? HTTPURLResponse
        return Response(data: data, error: error, statusCode: urlResponse?.statusCode)
    }
}
