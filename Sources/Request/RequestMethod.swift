//
//  RequestMethod.swift
//  Cara
//
//  Created by Jelle Vandebeeck on 02/12/2018.
//

import Foundation

/// The request methods available.
public enum RequestMethod {
    /// Request a representation of a resource.
    case get
    /// Request a representation of a resource but without the response body.
    case head
    /// Request to create a resource.
    case post
    /// Request to update or replace a resource.
    case put
    /// Request to update or modify a resource.
    case patch
    /// Request to delete a resource.
    case delete
}

extension RequestMethod {
    var httpMethod: String {
        switch self {
        case .get: return "GET"
        case .head: return "HEAD"
        case .post: return "POST"
        case .patch: return "PATCH"
        case .put: return "PUT"
        case .delete: return "DELETE"
        }
    }
}
