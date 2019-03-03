//
//  URLResponse+Error.swift
//  Cara
//
//  Created by Jelle Vandebeeck on 30/12/2018.
//

import Foundation

extension URLResponse {
    var responseError: ResponseError? {
        guard let response = self as? HTTPURLResponse else { return nil }
        return ResponseError(statusCode: response.statusCode)
    }
}
