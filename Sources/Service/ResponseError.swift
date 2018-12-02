//
//  ResponseError.swift
//  Cara
//
//  Created by Jelle Vandebeeck on 02/12/2018.
//

import Foundation

/// The error thrown by the service request.
enum ResponseError: Error {
    /// The request's url was invalid.
    case invalidURL
    /// An error occured because of the status code.
    case httpError(statusCode: Int)
}

extension ResponseError: Equatable {
    public static func == (lhs: ResponseError, rhs: ResponseError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, invalidURL): return true
        case (.httpError(let lhsStatusCode), httpError(let rhsStatusCode)): return lhsStatusCode == rhsStatusCode
        default: return false
        }
    }
}
