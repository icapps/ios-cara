//
//  Request+URLRequest.swift
//  Cara
//
//  Created by Jelle Vandebeeck on 02/12/2018.
//

import Foundation

extension Request {
    func makeURLRequest() throws -> URLRequest {
        // A correct url should be set.
        guard let url = url else { throw ResponseError.invalidURL }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        return urlRequest
    }
}
